*** Settings ***
Library    OperatingSystem
Library    SeleniumLibrary
Library    FakerLibrary    locale=pl_PL
Library    Dialogs
Library    Collections
Library    String


*** Variables ***
${URL}    https://www.zalando.pl
${email}    testerkawsb@gmail.com
${password}    Merito24
${invalid_data_message}    Coś poszło nie tak. Spróbuj wpisać swoje dane ponownie
${invalid_email_message}    Podaj pełny adres e-mail (np. jan.kowalski@domena.pl).
${invalid_password_message}    Wpis jest za krótki.
${no_email}    Wymagany adres e-mail
${no_password}    Wymagane hasło

*** Keywords ***
Open Browser To Zalando Homepage
    [Documentation]    Otwarcie przeglądarki Chrome i zmaksymalizowanie okna
    Open Browser    ${URL}    Chrome
    Maximize Browser Window

Login_to_account
    [Documentation]    Logowanie do konta
    [Arguments]    ${email}    ${password}
    Click Element    id=header-user-account-icon
    sleep    2
    ${is_new_page}=    Run Keyword And Return Status    Page Should Contain    W mgnieniu oka
    Run Keyword If    ${is_new_page}    New_login_page    ${email}    ${password}    ELSE    Old_login_page    ${email}    ${password}

Old_login_page
    [Documentation]    Logowanie do konta na starej stronie
    [Arguments]    ${email}    ${password}
    Wait Until Element Is Visible    id=login.email
    Input Text    id=login.email    ${email}
    Input Password    id=login.secret    ${password}
    Click Button    xpath=//*[@id="sso"]/div/div[2]/main/div/div[2]/div/div/div/form/button
    Wait Until Element Is Not Visible    xpath=//*[@id="sso"]/div/div[2]/main/div/div[2]/div/div/div/form/button

New_login_page
    [Documentation]    Logowanie do konta na nowej stronie
    [Arguments]    ${email}    ${password}
    Wait Until Element Is Visible    id=lookup-email
    Input Text    id=lookup-email    ${email}
    Click Element    xpath=//*[@id="theme-wrapper"]/main/section[1]/form/button
    Wait Until Element Is Visible    id=login-password
    Input Text    id=login-password    ${password}
    Click Element    xpath=//*[@id="theme-wrapper"]/main/section[3]/section[2]/form/button
    Wait Until Element Is Not Visible    xpath=//*[@id="theme-wrapper"]/main/section[3]/section[2]/form/button

#1. Testowanie Konta Użytkownika
        #1.1. Testowanie Poprawności Logowania

Valid_login
    [Documentation]    Logowanie użytkownika z poprawnymi danymi
    Login_to_account
    ...    email=${email}
    ...    password=${password}

Valid_login_page
    [Documentation]    Sprawdzenie, czy użytkownik jest przekierowywany do właściwej strony po udanym logowaniu
    Login_to_account
    ...    email=${email}
    ...    password=${password}
    Wait Until Page Contains    Twoje konto
    Page Should Contain    Twoje konto

Email_validation
    [Documentation]    Sprawdzenie poprawności maila
    Login_to_account
    ...    email=${email}
    ...    password=${password}
    Wait Until Page Contains    Twoje konto
    Click Element    xpath=//*[@id="main-content"]/div/div/div[1]/div/nav[2]/ul/li[1]/ul/li[6]/a/span
    Element Text Should Be    xpath=//*[@id="main-content"]/div/div/div[2]/x-wrapper-main/div/div/div[4]/div[1]/div[2]/div/div[2]    ${email}

Logout_of_account
    [Documentation]    Wylogowanie
    Login_to_account
    ...    email=${email}
    ...    password=${password}
    Wait Until Page Contains    Twoje konto
    Mouse Over    id=header-user-account-icon
    Wait Until Page Contains    Nie Testerka? Wyloguj się
    #pause execution
    Go to    https://www.zalando.pl/logout/
    sleep    3
    Mouse Over    id=header-user-account-icon
    Page Should Contain    Zaloguj się

         #1.2. Testowanie Błędnego Logowania
Invalid_login
    [Documentation]    Sprawdzenie poprawności komunikatu o błędnych danych logowania
    ${invalid_email}=        FakerLibrary.Email
    ${invalid_password}=     FakerLibrary.Password
    Login_to_account
    ...    email=${invalid_email}
    ...    password=${password}
    sleep    2
    ${message}=    get text    xpath=//*[@id="sso"]/div/div[2]/main/div/div[2]/div/div/div[1]/div/div/span
    should be equal as strings    ${invalid_data_message}   ${message}

Incomplete_email
    [Documentation]    Sprawdzenie komunikatu o niepełnym adresie email
    ${invalid_password}=     FakerLibrary.Password
    ${invalid_email}=    FakerLibrary.Word
    Login_to_account
    ...    email=${invalid_email}
    ...    password=${invalid_password}
    sleep    2
    ${message}=    get text    locator=//*[@id="sso"]/div/div[2]/main/div/div[2]/div/div/div/form/div[1]/div/div[2]/span
    should be equal as strings    ${invalid_email_message}   ${message}

Password_too_short
    [Documentation]    Sprawdzenie komunikatu o zbyt krótkim haśle
    ${invalid_password}=     FakerLibrary.Password   length=5
    Login_to_account
    ...    email=${email}
    ...    password=${invalid_password}
    sleep    2
    ${message}=    get text    xpath=//*[@id="sso"]/div/div[2]/main/div/div[2]/div/div/div/form/div[2]/div/div[2]/span
    should be equal as strings    ${invalid_password_message}   ${message}

Empty_email
    [Documentation]    Sprawdzenie komunikatu o braku emaila
    Login_to_account
    ...    email=${EMPTY}
    ...    password=${password}
    sleep    2
    ${message}=     get text    //*[@id="sso"]/div/div[2]/main/div/div[2]/div/div/div/form/div[1]/div/div[2]/span
    should be equal as strings    ${no_email}   ${message}

Empty_password
    [Documentation]    Sprawdzenie komunikatu o braku hasła
    Login_to_account
    ...    email=${email}
    ...    password=${EMPTY}
    sleep    2
    ${message}=     get text    //*[@id="sso"]/div/div[2]/main/div/div[2]/div/div/div/form/div[2]/div/div[2]/span
    should be equal as strings    ${no_password}   ${message}

#2. Testowanie Przeglądania Produktów
    #2.1. Testowanie Wyświetlania Produktów

Sort_from_lowest_price
    [Documentation]    Sortowanie po najniższej cenie
    Login_to_account
    ...    email=${email}
    ...    password=${password}
    pause execution
    wait until page does not contain    Witaj ponownie
    Click Element    link=Akcesoria
    wait until page contains    Liczba produktów:
    click element   xpath=//*[@id="main-content"]/div/div[6]/div/div[1]/aside/ul/li[1]/a/span
    wait until page contains    Akcesoria damskie - dodatki
    click element    link=Biżuteria
    wait until page contains    Biżuteria damska
    click button    //button[@aria-label='Sortuj']
    click element    //*[@id="collection_view_sort-dropdown"]/div[2]/div/form/div/div[3]/div/label/span    #od najniższej
    sleep    3


#3. Testowanie Koszyka Zakupowego
    #3.1. Testowanie Dodawania Produktów do Koszyka
Add_to_cart
    [Documentation]    Dodanie produktu do koszyka
    Login_to_account
    ...    email=${email}
    ...    password=${password}
    wait until page does not contain    Witaj ponownie
    click element    link=Promocje %
    wait until page contains    Liczba produktów
    #${product_text}=    Get WebElement    //*[@id="main-content"]/div/div[6]/div/div[2]/div[2]/div[2]/div[2]/div/article/a/figure/div/div/img
    #${product_name}=    get element attribute    ${product_text}    alt
    #log     ${product_name}
    click element    //*[@id="main-content"]/div/div[6]/div/div[1]/aside/ul/li[1]/a/span    #kobiety
    wait until page contains    Produkty damskie w promocji
    click element    //*[@id="main-content"]/div/div[6]/div/div[1]/aside/ul/li/ul/li[5]/a/span    #akcesoria
    wait until page contains    Akcesoria damskie w promocji
    click element    //*[@id="main-content"]/div/div[6]/div/div[1]/aside/ul/li/ul/li[5]/ul/li[1]/a/span    #torby i plecaki
    wait until page contains    Torby damskie w promocji
    scroll element into view    //*[@id="main-content"]/div/div[6]/div/div[1]/aside/ul/li/ul/li[7]/a/span
    click element    //*[@id="main-content"]/div/div[6]/div/div[2]/div[2]/div[2]/div[2]/div/article/a/figure/div/div/img
    wait until page contains    Dodaj do koszyka
    #${product_text_2}=    Get WebElement    //*[@id="main-content"]/div[1]/div/div[2]/h1/span
    #${product_name_2}=    get element attribute    ${product_text_2}    innerText
    #log    ${product_name_2}
    #should be equal    ${product_name}    ${product_name_2}
    click element    xpath://button[contains(@class, 'vfoVrE') and contains(@class, 'heWLCX') and contains(span, 'Dodaj do koszyka')]
    #tu sprawdzic czy dodało
    pause execution
    sleep    2


    #3.2. Testowanie Usuwania Produktów z Koszyka
Remove_from_cart
    [Documentation]    Dodanie produktu do koszyka
    Login_to_account
    ...    email=${email}
    ...    password=${password}
    wait until page does not contain    Witaj ponownie
    click element    link=Promocje %
    wait until page contains    Liczba produktów
    #${product_text}=    Get WebElement    //*[@id="main-content"]/div/div[6]/div/div[2]/div[2]/div[2]/div[2]/div/article/a/figure/div/div/img
    #${product_name}=    get element attribute    ${product_text}    alt
    #log     ${product_name}
    click element    //*[@id="main-content"]/div/div[6]/div/div[1]/aside/ul/li[1]/a/span    #kobiety
    wait until page contains    Produkty damskie w promocji
    click element    //*[@id="main-content"]/div/div[6]/div/div[1]/aside/ul/li/ul/li[5]/a/span    #akcesoria
    wait until page contains    Akcesoria damskie w promocji
    click element    //*[@id="main-content"]/div/div[6]/div/div[1]/aside/ul/li/ul/li[5]/ul/li[1]/a/span    #torby i plecaki
    wait until page contains    Torby damskie w promocji
    scroll element into view    //*[@id="main-content"]/div/div[6]/div/div[1]/aside/ul/li/ul/li[7]/a/span
    click element    //*[@id="main-content"]/div/div[6]/div/div[2]/div[2]/div[2]/div[2]/div/article/a/figure/div/div/img
    wait until page contains    Dodaj do koszyka
    #${product_text_2}=    Get WebElement    //*[@id="main-content"]/div[1]/div/div[2]/h1/span
    #${product_name_2}=    get element attribute    ${product_text_2}    innerText
    #log    ${product_name_2}
    #should be equal    ${product_name}    ${product_name_2}
    click element    xpath://button[contains(@class, 'vfoVrE') and contains(@class, 'heWLCX') and contains(span, 'Dodaj do koszyka')]
    # tutaj usunac z koszyka

    pause execution
    sleep    2






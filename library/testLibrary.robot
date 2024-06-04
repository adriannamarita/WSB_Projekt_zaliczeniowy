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
    Run Keyword    Click Element  id=header-user-account-icon
    Wait Until Element Is Visible    id=login.email
    Input Text    id=login.email    ${email}
    Input Password    id=login.secret    ${password}
    Click Button    locator=//*[@id="sso"]/div/div[2]/main/div/div[2]/div/div/div/form/button


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

PT10
    [Documentation]    Sortowanie
    Login_to_account
    ...    email=${email}
    ...    password=${password}
    click element   xpath=/html/body/div[4]/div/x-wrapper-re-1-4/div/div/div[2]/div[1]/div/div[1]/div/nav/ul/li[5]/span/a/span
    click element    xpath=//*[@id="main-content"]/div/div[6]/div/div[1]/aside/ul/li[1]/a/span
    click button    xpath=//*[@id=":r2j:"]
    click element    //*[@id="collection_view_sort-dropdown"]/div[2]/div/form/div/div[5]/div/label/span

#3. Testowanie Koszyka Zakupowego
    #3.1. Testowanie Dodawania Produktów do Koszyka





    #3.2. Testowanie Usuwania Produktów z Koszyka








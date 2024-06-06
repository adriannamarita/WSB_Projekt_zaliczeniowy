*** Settings ***
Library    OperatingSystem
Library    SeleniumLibrary
Library    FakerLibrary    locale=pl_PL
Library    Dialogs
Library    Collections
Resource     library/testLibrary.robot


Test Setup    Open Browser To Zalando Homepage
Test Teardown     close browser


*** Test Cases ***
Test_Case_1
    Valid_login

Test_Case_2
    Valid_login_page

Test_Case_3
    Email_validation

Test_Case_4
    Logout_of_account

Test_Case_5
    Invalid_login

Test_Case_6
    Incomplete_email

Test_Case_7
    Password_too_short

Test_Case_8
    Empty_email

Test_Case_9
    Empty_password

Test_Case_10
    Sort_from_lowest_price

Test_Case_11
    Add_to_cart

Test_Case_12
    Verification_of_added_product

Test_Case_13
    Remove_from_cart
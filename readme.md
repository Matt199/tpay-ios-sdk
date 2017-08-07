[English Version](https://github.com/tpay-com/IOS-SDK/blob/master/readme.md#english-version)

Tpay iOS Mobile Library
=============================

Biblioteka mobilna przygotowana dla systemu iOS.

Konfiguracja
------------

Biblioteka wspiera iOS w wersji 9.0 lub nowszej. W środowisku Xcode należy
dołączyć do projektu TpaySDK.framework.

-   Dokumentacja Apple
https://developer.apple.com/library/ios/recipes/xcode_help-project_editor/Articles/AddingaLibrarytoaTarget.html

-   Biblioteka zależy od frameworków UIKit oraz Foundation, dołączonych wraz z
TpaySDK.

Budowa
------

**TpayPayment** - model płatności.

**TpayViewController** - kontroler widoku płatności.

**TpayPaymentDelegate** - delegat dostarczający informację zwrotną o
statusie transakcji.

Framework wykorzystuje parametry *mReturnUrl* oraz *mReturnErrorUrl* do
ustalenia statusu transakcji. W przypadku braku uzupełnienia zostaną nadane im
domyślne wartości.

Sposób użycia
-------------

Poniżej opisano możliwy sposób implementacji w projekcie przy użyciu Storyboard.

-   Po poprawnym skonfigurowaniu projektu utwórz w *Storyboard*zie pusty
*ViewController* nazwijmy go *PaymentViewController*.

-   Utwórz segue oraz nazwij *Identifier* do kontrolera np.
*TpayPaymentInnerSegue*.

-   W utworzonym *ViewController*ze ustaw *Custom Class* na
*TpayViewController*.

-   Następnie w pliku *PaymentViewController.h* dołącz nagłówek:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#import <TpaySDK/TpayViewController.h>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-   Pozostając w tym samym pliku zadeklaruj implementację protokołu
*TpayPaymentDelegate* w kontrolerze *TpayViewController*
(możesz również dokonać tego w wewnętrzym interfejsie).

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@interface PaymentViewController : UIViewController <TpayPaymentDelegate>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-   Przejdź do implementacji kontrolera *PaymentViewController.m*.

-   Utwórz w nim płatność i ustaw wymagane parametry zgodnie z dokumentacją.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
self.payment = [TpayPayment new];

self.payment.mId = @"twoje_id";
self.payment.mAmount = @"kwota_transakcji";
self.payment.mDescription = @"opis_transakcji";
self.payment.mClientEmail = @"email_klienta";
self.payment.mClientName = @"imie_nazwisko_klienta";
self.payment.md5 = @"obliczony_md5";

// W przypadku braku obliczonego MD5:

self.payment.mCrc = @"crc";
self.payment.mSecurityCode = @"twój_kod"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Można również ustawić gotowy, wygenerowany wcześniej link i wtedy konfiguracja
obiektu reprezentującego płatność wygląda jak poniżej:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
self.payment.mPaymentLink = @"wygenerowany_link_płatności";
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-   Aby rozpocząc proces płatności należy utworzyć *TpayViewController*.
W chwili wywołania wykonywany jest segue, który trzeba nazwać w
*Storyboard*zie i przechwycić, w nim należy przekazać naszą płatność do
wewnętrznego kontrolera oraz ustawić delegata dla zdarzeń.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
NSString *segueName = segue.identifier;
if ([segueName isEqualToString: @"TpayPaymentInnerSegue"]) {
TpayViewController *childViewController = (TpayViewController *) [segue destinationViewController];
childViewController.payment = self.payment;
childViewController.delegate = self;
}
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Należy się upewnić, że została ona wcześniej odpowiednio utworzona.

-   Należy też dodać metody infromujące o przebiegu transakcji.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)tpayDidSucceedWithPayment:(TpayPayment *)payment

- (void)tpayDidFailedWithPayment:(TpayPayment *)payment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-   Jeżeli używamy metod zachowywania stanu aplikacji. Należy pamietąć o
implementacji odpowiednich metod. Obiekt TpayPayment może być
kodowany i dekodowany za pomocą klasy *NSCoder*.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
[coder encodeObject:self.payment forKey:kExtraPayment];
[super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
self.payment = [coder decodeObjectForKey:kExtraPayment];
[super decodeRestorableStateWithCoder:coder];
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
### Sposób użycia biblioteki w projekcie - płatności BLIK oraz BLIK OneClick
#### Użycie domyślnych widoków

Biblioteka pozwala na szybkie użycie płatności BLIK oraz BLIK One Click za pomocą gotowych, domyślnych widoków płatności.

W pierwszym kroku należy stworzyć obiekt reprezentujący transakcję BLIK::
```
TpayBlikTransaction *transaction = [TpayBlikTransaction new];
transaction.mApiPassword = @"haslo_api";
transaction.mId = @"twoje_id";
transaction.mAmount = @"kwota_transakcji";
transaction.mCrc = @"kod_crc";
transaction.mSecurityCode = @"kod_bezpieczeństwa";
transaction.mDescription = @"opis_transakcji";
transaction.mClientEmail = @"email_klienta";
transaction.mClientName = @"imie_nazwisko_klienta";
[transaction addBlikAlias:@"alias_blik" withLabel:@"etykieta" 
andKey:@"klucz_aplikacji"];
```

Hasło do api (parametr *api_password*) jest polem obowiązkowym - w [dokumentacji API ](https://secure.tpay.com/partner/pliki/api-transaction.pdf) na stronie 2. można znaleźć więcej szczegółów.  Pozostałe parametry opisane są w [dokumentacji ogólnej](https://secure.transferuj.pl/partner/pliki/dokumentacja.pdf). 

Zamiast podawania parametrów *security code* i *crc*, można podać parametr *md5 code*, który wygenerować można zgodnie z [dokumentacją](https://secure.transferuj.pl/partner/pliki/dokumentacja.pdf).

W przypadku transakcji BLIK bez możliwości rejestracji aliasu (czyli bez możliwości skorzystania z One Click) dodanie aliasu BLIK jest opcjonalne. W przypadku transakcji dla zarejestrowanego aliasu, bądź chęci rejestracji aliasu należy podać przynajmniej jeden alias za pomocą metody *addBlikAlias()*. 

Metoda *addBlikAlias()* przyjmuje parametry:
- alias: pole obowiązkowe, typ NString
- label: etykieta aliasu, pole opcjonalne, typ NString
- key: numer aplikacji, pole opcjonalne, typ NString.

Więcej informacji na temat poszczególnych parametrów zawarto w [dokumentacji API ](https://secure.tpay.com/partner/pliki/api-transaction.pdf) na stronie 7.

Jeden alias BLIK może być zarejestrowany do wielu aplikacji bankowych, co powoduje niejednoznaczność aliasu - domyślny widok płatności obsługuje tę sytuację wyświetlając stosowny widok wyboru.

Kolejnym krokiem, pozwalającym na wyświetlenie domyślnego widoku płatności, jest inicjalizacja storyboardu zawierającego kontroler widoku płatności,  następnie jego zainicjowanie oraz przekazanie odpowiednich parametrów:
```
UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TpayBlikStoryboard" 
bundle: [NSBundle bundleWithIdentifier:@"com.tpay.TpaySDK"]];
TpayBlikTransactionViewController *blikDefaultVC = (TpayBlikTransactionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TpayBlikTransactionViewController"];
blikDefaultVC.blikDelegate = delegate;
blikDefaultVC.blikTransaction = transaction;
blikDefaultVC.key = @"apiKey";
blikDefaultVC.viewType = viewType;
```

Przekazywane parametry:
- blikDelegate - delegat dostarczający informację zwrotną z API
- blikTransaction - obiekt transakcji stworzony w kroku 1.
- key - unikalny ciąg dostępu, wygenerowany w Panelu Odbiorcy Płatności w zakładce
Ustawienia->API
- viewType: jedna z wartości kRegisteredAlias, kUnregisteredAlias, kOnlyBlik.

Typ widoku, który powiniśmy wybrać zależny jest od typu transakcji, którą chcemy przeprowadzić:
- kOnlyBlik - pokazuje widok pozwalający dokonać jedynie transakcji BLIK, bez możliwości rejestracji aliasu (dodawanie aliasu do obiektu transakcji nie jest wtedy konieczne)
- kUnregisteredAlias - pokazuje widok pozwalający dokonać transakcji BLIK z możliwością wyrażenia chęci rejestracji aliasu
- kRegisteredAlias - pokazuje widok płatności dla zarejestrowanego aliasu.

Ponadto dostępny jest również typ kNonUniqueAlias, używany wewnątrz biblioteki do obsługi sytuacji niejednoznaczego aliasu BLIK.

Następnie należy zaprezentować kontroler widoku płatności:

```
[self.navigationController pushViewController:blikDefaultVC animated:YES];
```

Ostatni krok to rozszerzenie klasy, która obsługiwać będzie odpowiedź zwrotną z API o obsługę protokołu TpayBlikTransactionDelegate. 

Przykład: Jeśli zaprezentowaliśmy kontroler widoku płatności z kontrolera MyViewController,
to powinniśmy ustawić pole:

```
blikDefaultVC.blikDelegate = self;
```
natomiast klasa MyViewController powinna rozszerzać protokół TpayBlikTransactionDelegate:

```
@interface MyViewController () <TpayBlikTransactionDelegate>
```
Implementacja kontrolera MyViewController powinna zawierać metody:

```
- (void) tpayDidSucceedWithBlikTransaction:(TpayBlikTransaction *)transaction 
andResponse: (id)responseObject {
// Transakcja poprawna. 
// Klient powinien zatwierdzić płatność
// w aplikacji mobilnej banku. 
// Poczekaj na powiadomienie.  
}

- (void) tpayDidFailedWithBlikTransaction:(TpayBlikTransaction *)transaction 
andResponse: (id)responseObject {
// Wystąpił błąd. 
// Odpowiedź jest klasy NSDictionary, jeśli przyszedł błąd z API.
// Odpowiedź jest klasy NSError, jeśli jest to inny błąd, 
// np. brak połączenia z internetem.
// Więcej w dokumentacji API.
}
```

#### Samodzielna obsługa płatności BLIK i BLIK One Click
Biblioteka zawiera metody pozwalające na obsługę płatności bez wykorzystania domyślnych widoków. 

Należy stworzyć obiekt reprezentujący transakcję BLIK:

```
TpayBlikTransaction *transaction = [TpayBlikTransaction new];
transaction.mApiPassword = @"haslo_api";
transaction.mId = @"twoje_id";
transaction.mAmount = @"kwota_transakcji";
transaction.mCrc = @"kod_crc";
transaction.mSecurityCode = @"kod_bezpieczeństwa";
transaction.mDescription = @"opis_transakcji";
transaction.mClientEmail = @"email_klienta";
transaction.mClientName = @"imie_nazwisko_klienta";
transaction.mBlikCode = "6_cyfrowy_kod_blik";
[transaction addBlikAlias:@"alias_blik" withLabel:@"etykieta" 
andKey:@"klucz_aplikacji"];
```

Szczegółowy opis w sekcji *Użycie domyślnych widoków*.

Następnie należy skorzystać z klienta pozwalającego na wysłanie transakcji oraz przekazać delegata, który obsłuży odpowiedź zwrotną z API (zgodnie z ostatnim punktem sekcji *Użycie domyślnych widoków*):

```
TpayApiClient *client = [TpayApiClient new];
client.delegate = delegate;
[client payWithBlikTransaction:transaction withKey:@"apiKey"];
```

Szczegóły związane z odpowiedziami API oraz kodami błędów znajdują się w [dokumentacji API ](https://secure.tpay.com/partner/pliki/api-transaction.pdf) na stronach 6-13.

Historia zmian
--------------

Wersja 1.0 (Czerwiec 2015)
Wersja 2.0 (Maj 2017)
Wersja 3.0 (Lipiec 2017)

### English Version

### Tpay iOS Mobile Library

Mobile Library prepared for iOS.

Configuration
-------------

The library supports iOS 9.0 or later. In the Xcode environment, the TpaySDK.framework should be added to the project.
Apple documentation https://developer.apple.com/library/ios/recipes/xcode_help-project_editor/Articles/AddingaLibrarytoaTarget.html

- The library depends on UIKit and Foundation frameworks, which are included with TpaySDK.

Formation
---------

**TpayPayment** - payment model.
**TpayViewController** - payment view controller.
**TpayPaymentDelegate** - delegate providing feedback on transaction status.

The framework uses mReturnUrl and mReturnErrorUrl parameters to determine the status of the transaction. In case of non-completion, default values will be assigned to them.

How to use
----------

Below is a possible way of implementation in a project using Storyboard.

- After properly configured the project, create empty *ViewController* in *Storyboard* let's call it *PaymentViewController*.

- Create a segue and name the Identifier for the controller e.g. *TpayPaymentInnerSegue*.

- In the created *ViewController*, set the *Custom Class* on *TpayViewController*.

- Then, in the PaymentViewController.h file, include the header:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#import <TpaySDK/TpayViewController.h>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Staying in the same file, declare the implementation of the TpayPaymentDelegate protocol in the TpayViewController (you can also do this in the internal interface).
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
@interface PaymentViewController : UIViewController <TpayPaymentDelegate>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Go to the implementation of *PaymentViewController.m* controller.

- Create a payment in it and set the required parameters according to the documentation.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
self.payment = [TpayPayment new];

self.payment.mId = @"your_id";
self.payment.mAmount = @"transaction_amount";
self.payment.mDescription = @"transaction_description";
self.payment.mClientEmail = @"customer_email";
self.payment.mClientName = @"customer_name_surname";
self.payment.md5 = @"md5_calculated";

// If md5 is not calculated:

self.payment.mCrc = @"crc";
self.payment.mSecurityCode = @"your_code"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You can also set up a pre-generated link, and then the configuration of the payment object looks like this:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
self.payment.mPaymentLink = @"generated_payment_link";
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- To start the payment process, create a *TpayViewController*. At the time of the call, a segue is executed, which must be called in *Storyboard* and intercepted; the payment should be transferred to the internal controller and the delegate for the events should be set.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
NSString *segueName = segue.identifier;
if ([segueName isEqualToString: @"TpayPaymentInnerSegue"]) {
TpayViewController *childViewController = (TpayViewController *) [segue destinationViewController];
childViewController.payment = self.payment;
childViewController.delegate = self;
}
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Make sure that it has been properly created beforehand.

-   Methods informing about the course of the transaction should also be added

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)tpayDidSucceedWithPayment:(TpayPayment *)payment

- (void)tpayDidFailedWithPayment:(TpayPayment *)payment
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

-   If you use application state retention methods, remember to implement the appropriate methods. The TpayPayment object can be encoded and decoded using the NSCoder class.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
[coder encodeObject:self.payment forKey:kExtraPayment];
[super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
self.payment = [coder decodeObjectForKey:kExtraPayment];
[super decodeRestorableStateWithCoder:coder];
}
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

### How to use the library in the project - BLIK and BLIK OneClick payments
#### The use of default views

The library allows you to quickly use BLIK and BLIK One Click payments using the default payment views.

In the first step, create an object representing the BLIK transaction:
```
TpayBlikTransaction *transaction = [TpayBlikTransaction new];
transaction.mApiPassword = @"api_password";
transaction.mId = @"your_id";
transaction.mAmount = @"transaction_amount";
transaction.mCrc = @"crc_code";
transaction.mSecurityCode = @"security_code";
transaction.mDescription = @"transaction_description";
transaction.mClientEmail = @"customer_email";
transaction.mClientName = @"customer_name_surname";
[transaction addBlikAlias:@"alias_blik" withLabel:@"label" 
andKey:@"application_key"];
```

The api password (api_password parameter) is a mandatory field - see API documentation on page 2 for more details. Other parameters are described in the general documentation.

Instead of providing security code and crc parameters, you can specify the md5 code parameter that can be generated according to the documentation.

In the case of BLIK transactions without the ability to register an alias (ie without the ability to use One Click), adding a BLIK alias is optional. In the case of transactions for a registered alias or wanting to register an alias, you must specify at least one alias using the *addBlikAlias()* method.

The *addBlikAlias()* method takes the following parameters:

- alias: mandatory field, NString type
- label: alias label, optional field, NString type
- key: application number, optional field, NString type.

For more information on individual parameters, see the API documentation on page 7.

One BLIK alias can be registered to multiple banking applications, resulting in alias ambiguity - the default payment view handles this situation by displaying the corresponding selection view.

The next step to display the default payment view is the initialisation of the storyboard containing the payment view controller, then its initiation and passing the appropriate parameters:
```
UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"TpayBlikStoryboard" 
bundle: [NSBundle bundleWithIdentifier:@"com.tpay.TpaySDK"]];
TpayBlikTransactionViewController *blikDefaultVC = (TpayBlikTransactionViewController *)[storyboard instantiateViewControllerWithIdentifier:@"TpayBlikTransactionViewController"];
blikDefaultVC.blikDelegate = delegate;
blikDefaultVC.blikTransaction = transaction;
blikDefaultVC.key = @"apiKey";
blikDefaultVC.viewType = viewType;
```

Passed parameters:
- blikDelegate - delegate providing API feedback
- blikTransaction - transaction object created in step 1.
- key - unique access string, generated in the Merchant Panel in the Settings-> API tab
- viewType: one of the values kRegisteredAlias, kUnregisteredAlias, kOnlyBlik.

The type of view that we should choose depends on the type of transaction we want to perform:
- kOnlyBlik - shows a view allowing only BLIK transactions, without the ability to register an alias (adding an alias to the transaction object is not necessary)
- kUnregisteredAlias - shows a view allowing BLIK transaction with the ability to express the desire to register an alias
- kRegisteredAlias - shows a payment view for the registered alias.

In addition, the type kNonUniqueAlias is also available, which is used inside a library to handle ambiguous BLIK aliases.

Then, the payment view controller should be presented:
```
[self.navigationController pushViewController:blikDefaultVC animated:YES];
```

The last step is a class extension that will handle the API feedback for TpayBlikTransactionDelegate protocol support.

Example: If you presented the payment view controller from MyViewController, the following field should be set:
```
blikDefaultVC.blikDelegate = self;
```
The MyViewController class should extend the TpayBlikTransactionDelegate protocol:
```
@interface MyViewController () <TpayBlikTransactionDelegate>
```
Implementing the MyViewController should include the following methods:
```
- (void) tpayDidSucceedWithBlikTransaction:(TpayBlikTransaction *)transaction 
andResponse: (id)responseObject {
// Correct transaction. 
// The customer should approve the payment
// in the bank mobile application. 
// Wait for the notification.  
}

- (void) tpayDidFailedWithBlikTransaction:(TpayBlikTransaction *)transaction 
andResponse: (id)responseObject {
// An error occured. 
// The answer is the NSDictionary class, if the error came from the API.
// The answer is NSError class, if this is another error, 
// e.g. no internet connection.
// More in API documentation.
}
```

### Self-service of BLIK and BLIK One Click payments
The library provides methods for handling payments without using default views.

Create an object representing the BLIK transaction:

```
TpayBlikTransaction *transaction = [TpayBlikTransaction new];
transaction.mApiPassword = @"api_password";
transaction.mId = @"your_id";
transaction.mAmount = @"transaction_amount";
transaction.mCrc = @"crc_code";
transaction.mSecurityCode = @"security_code";
transaction.mDescription = @"transaction_description";
transaction.mClientEmail = @"customer_email";
transaction.mClientName = @"customer_name_surname";
transaction.mBlikCode = "6_digit_blik_code";
[transaction addBlikAlias:@"alias_blik" withLabel:@"label" 
andKey:@"application_key"];
```

For details see Using default views.

Then, use the client allowing to send the transaction and forward the delegate who will handle the API feedback (according to the last section of the Using Default Views section):
```
TpayApiClient *client = [TpayApiClient new];
client.delegate = delegate;
[client payWithBlikTransaction:transaction withKey:@"apiKey"];
```

Details regarding API responses and error codes can be found in the API documentation on pages 6-13.

History of changes
------------------

Version 1.0 (June 2015) Version 2.0 (May 2017) Version 3.0 (July 2017)

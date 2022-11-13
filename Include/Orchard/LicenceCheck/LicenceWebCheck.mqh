/*
   LicenceWebCheck.mqh
   Copyright 2021, Orchard Forex
   https://www.orchardforex.com
*/

#property copyright "Copyright 2013-2020, Orchard Forex"
#property link "https://www.orchardforex.com"
#property version "1.00"

// this is important for MT4
#property strict

#include "LicenceFileCheck.mqh"

class CLicenceWeb : public CLicenceFile {

protected:
   string         mAccount;
   string         mRegistration;

   virtual bool   LoadData( string &data );
   virtual string LicencePath();

public:
   CLicenceWeb( string productName, string productKey, string registration, long account = -1 );
   ~CLicenceWeb() {}
};

CLicenceWeb::CLicenceWeb( string productName, string productKey, string registration, long account = -1 ) : CLicenceFile( productName, productKey ) {

   mRegistration = registration;
   if ( account < 0 ) {
      account = AccountInfoInteger( ACCOUNT_LOGIN );
   }
   mAccount = string( account );
}

string CLicenceWeb::LicencePath() { return ( "Orchard\\Licence\\" + Hash( mProductName + "_" + mAccount ) + ".lic" ); }

bool   CLicenceWeb::LoadData( string &data ) {

   string headers = "";
   char   postData[];
   char   resultData[];
   string resultHeaders;
   int    timeout = 5000; // 1 second, may be too short for a slow connection
   string api     = StringFormat( "https://drive.google.com/uc?id=%s&export=download", mRegistration );

   ResetLastError();
   int response  = WebRequest( "GET", api, headers, timeout, postData, resultData, resultHeaders );
   int errorCode = GetLastError();
   data          = CharArrayToString( resultData );

   switch ( response ) {
   case -1:
      Print( "Error in WebRequest. Error code  =", errorCode );
      Print( "Add the address https://drive.google.com in the list of allowed URLs" );
      return false;
      break;
   case 200:
      //--- Success
      return true;
      break;
   default:
      return false;
      break;
   }

   return false;
}

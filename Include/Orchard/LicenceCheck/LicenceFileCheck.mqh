/*
   LicenceFileCheck.mqh
   Copyright 2021, Orchard Forex
   https://www.orchardforex.com
*/

#property copyright "Copyright 2013-2020, Orchard Forex"
#property link "https://www.orchardforex.com"
#property version "1.00"

// this is important
#property strict

class CLicenceFile {

protected:
   string         mProductName;
   string         mProductKey;
   string         mData;

   virtual string LicencePath();

public:
   CLicenceFile( string productName, string productKey );
   ~CLicenceFile() {}

   bool         Check();
   virtual bool LoadData( string &data );
   string       KeyGen( string data ); //	Allow account to pass in
   string       Hash( string data );
   bool         FileGen( string data );

   string       GetData() { return ( mData ); }
};

CLicenceFile::CLicenceFile( string productName, string productKey ) {

   mProductName = productName;
   mProductKey  = productKey;
}

string CLicenceFile::LicencePath() { return ( "Orchard\\Licence\\" + mProductName + ".lic" ); }

bool   CLicenceFile::Check() {

   mData       = "";
   string data = "";
   if ( !LoadData( data ) ) return false;

   int pos = StringFind( data, "\n" );
   if ( pos <= 0 ) {
      Print( "Licence file is not valid" );
      return ( false );
   }

   string signature = StringSubstr( data, 0, pos );
   mData            = StringSubstr( data, pos + 1 );

   string key       = KeyGen( mData );
   if ( key != signature ) {
      Print( "Licence is invalid" );
      return ( false );
   }

   return ( true );
}

bool CLicenceFile::LoadData( string &data ) {

   string licencePath = LicencePath();

   //	Open and read the file each time in case it has been modified between iterations
   int    handle      = FileOpen( licencePath, FILE_READ | FILE_BIN );
   if ( handle == INVALID_HANDLE ) {
      PrintFormat( "Could not open licence file %s", licencePath );
      return ( false );
   }

   int len = ( int )FileSize( handle );
   data    = FileReadString( handle, len );
   FileClose( handle );

   return true;
}

string CLicenceFile::KeyGen( string data ) {

   string keyString = data + mProductKey;
   return Hash( keyString );
}

string CLicenceFile::Hash( string data ) {

   uchar dataChar[];
   StringToCharArray( data, dataChar, 0, StringLen( data ) );

   uchar cryptChar[];
   CryptEncode( CRYPT_HASH_SHA256, dataChar, dataChar, cryptChar );

   string result = "";
   int    count  = ArraySize( cryptChar );
   for ( int i = 0; i < count; i++ ) {
      result += StringFormat( "%.2x", cryptChar[i] );
   }
   return result;
}

bool CLicenceFile::FileGen( string data ) {

   string licencePath = LicencePath();

   int    handle      = FileOpen( licencePath, FILE_WRITE | FILE_BIN );
   if ( handle == INVALID_HANDLE ) {
      PrintFormat( "Could not create licence file %s", licencePath );
      return ( false );
   }

   string signature = KeyGen( data );
   string contents  = signature + "\n" + data;
   FileWriteString( handle, contents );
   FileFlush( handle );
   FileClose( handle );

   Print( "Licence file '" + licencePath + "' created" );
   return ( true );
}


# Salesforce LWC and Apex Integration Project

## Overview

This project is built on the Salesforce Lightning Web Components (LWC) framework and Apex to provide dynamic product management functionality. The project integrates RESTful API calls via Named Credentials, data filtering, and business logic mapping for products and their reviews into a Custom Application

### Architecture

1. **Apex Classes**:
   - **`ProductCallout`**:
     - Makes callouts to an external API. Named credentials are used for security and protection.
     - Deserializes JSON responses into a Salesforce custom object structure.
     - Processes related product reviews and links them to products.

   - **`DummyProductMapping`**:
     - Preparation and mapping of fields of the received temporary object into objects on Salesforce

   - **`JsonParserProduct`**:
     - temporary object for storing data from Json
   
   - **`DummyProductTile`**:
     - Handles product filtering and data retrieval based on user input.
     - Retrieves filtered product data using an Apex call.
     
   - **`DummyProductTileTest , ProductCalloutTest`**:  
     - Test classes covering more than 75% of the code, which allows for deployment to other organizations


2. **Lightning Web Components (LWC)**:
   - **`DummyProductInTile`**:
     - Provides an interface for users to filter and view product data.
     - Displays dynamic data such as product stock and unit price.
     - Includes navigation logic to redirect users to product records within Salesforce.

3. **Data Handling**:
   - **Product Data**: Main object
   - **Review Data**: Linked to products via Master-Details relationships

4. **Custom Application**:
   - **Dummy_Products**: allows to display the necessary information for product presentation, includes two tabs, on one of which is displayed the developed component, on the second sheet of records with a transition to information about one record

5. **RESTful API callouts**:
    -  To secure and simplify authenticated API callouts to external system used Named Credentials (Winter ’23 update)

### Metadata types in project for deploy
   - ApexClass
   - LightningComponentBundle
   - CustomObject
   - CustomApplication
   - CustomTab
   - FlexiPage
   - Profile
   - NamedCredential
   - ExternalCredential


### Setup instructions for System Administrator User
	
Use this URL to install the package into any organization:
https://login.salesforce.com/packaging/installPackage.apexp?p0=04tQy0000003VaL

Note: If you are installing into a sandbox organization you must replace the initial portion of the URL with http://test.salesforce.com

**Steps after installation**:

1. **Enabled External Credential Principal Access**:
  - Setup 
         -> Profiles 
         -> System Administrator profile 
         -> Enabled External Credential Principal Access 
         -> Edit 
         -> Add to: Enabled External Credential Principals - D_Product_Ext_Credential - Admin User 
         -> Save

2. **Setup Named Credensials(Principals)**:
   - Setup
         -> Named Credentials
         -> External Credentials
         -> D_Product_Ext_Credential
         -> Principals : Admin User
         -> Edit
         -> fill fields: Username : 'emilys' , Password : 'emilyspass' //open data, user's credentials from dummyjson.com/users
         -> Save

3. **Start App**:
   - Home page
         -> App Launcher
         -> Dummy Products
         -> Enjoy!
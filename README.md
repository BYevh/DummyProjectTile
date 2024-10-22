
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

### Setup Instructions

1. **Clone the Repository**:
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Deploy Apex Classes and LWC to Salesforce**:
   - Use SFDX (Salesforce DX) to push the Apex classes and LWC components to your Salesforce org.
   ```bash
   sfdx force:source:push
   ```

3. **Assign Permissions**:
   - Ensure that necessary permissions are granted to users who will interact with the LWC and Apex components.

4. **Testing**:
   - Run the Apex test classes to ensure that the project components function as expected.
   ```bash
   sfdx force:apex:test:run --resultformat human
   ```

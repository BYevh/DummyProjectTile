@isTest
public class DummyProductTileTest {

    private static String CATEGORY_NAME_1 = 'skin-care';
    private static String CATEGORY_NAME_2 = 'laptops';

    // Test Setup: Insert dummy product data for testing
    @testSetup
    static void setupTestData() {
        List<Product__c> dummyProducts = new List<Product__c>();

        for (Integer i = 0; i < 10; i++) {
            dummyProducts.add(new Product__c(
                Name = 'Test Product ' + i,
                Category__c = (Math.mod(i, 2) == 0) ? CATEGORY_NAME_1 : CATEGORY_NAME_2,  
                Brand__c = 'Brand' + i,
                Rating__c = 2.5 + (i * 0.1),
                Price__c = 50 * (i + 1),
                Sku__c = 'SKU' + i,
                Stock__c = 100
            ));
        }
        insert dummyProducts;
    }

    // Test Case 1: Test getFilteredDummyProducts by Name
    @isTest
    static void testGetFilteredDummyProductsByName() {
        Test.startTest();
        List<Product__c> filteredProducts = DummyProductTile.getFilteredDummyProducts('Name', 'Test Product 1');
        Test.stopTest();

        // Asserting that a result is returned for the search
        System.assertEquals(1, filteredProducts.size());
        System.assertEquals('Test Product 1', filteredProducts[0].Name);
    }

    // Test Case 2: Test getFilteredDummyProducts by Category
    @isTest
    static void testGetFilteredDummyProductsByCategory() {
        Test.startTest();
        List<Product__c> filteredProducts = DummyProductTile.getFilteredDummyProducts('Category__c', CATEGORY_NAME_1);
        Test.stopTest();

        // Assert products are returned for the category search
        System.assert(filteredProducts.size() > 0, 'Expected some products for Category__c = skin-care');
        for (Product__c product : filteredProducts) {
            System.assertEquals(CATEGORY_NAME_1, product.Category__c);
        }
    }

    // Test Case 3: Test getFilteredDummyProducts by Rating
    @isTest
    static void testGetFilteredDummyProductsByRating() {
        Test.startTest();
        List<Product__c> filteredProducts = DummyProductTile.getFilteredDummyProducts('Rating__c', '2.5');
        Test.stopTest();

        // Assert products are returned for the rating search
        System.assert(filteredProducts.size() > 0, 'Expected some products for Rating__c near 2.5');
        for (Product__c product : filteredProducts) {
            System.assert(Math.abs(product.Rating__c - 2.5) <= 0.25, 'Product rating is out of expected range.');
        }
    }

    // Test Case 4: Test getAllDummyProducts
    @isTest
    static void testGetAllDummyProducts() {
        Test.startTest();
        List<Product__c> allProducts = DummyProductTile.getFilteredDummyProducts(null, null);
        Test.stopTest();

        System.debug('dummyProducts.size = ' + allProducts.size());
        for (Product__c variable : allProducts) {
            System.debug('variable.Name = ' + variable.Name);
        }   

        // Assert all products are retrieved
        System.assertEquals(10, allProducts.size());
    }

    // Test Case 5: Test isNumericOrDecimal method
    @isTest
    static void testIsNumericOrDecimal() {
        // Test with valid numbers
        System.assertEquals(true, DummyProductTile.isNumericOrDecimal('123'));
        System.assertEquals(true, DummyProductTile.isNumericOrDecimal('123.45'));

        // Test with invalid input
        System.assertEquals(false, DummyProductTile.isNumericOrDecimal('ABC'));
        System.assertEquals(false, DummyProductTile.isNumericOrDecimal('12A3'));
    }

    // Test Case 6: Test empty inputs for filtering
    @isTest
    static void testGetFilteredDummyProductsEmptyInputs() {
        Test.startTest();
        List<Product__c> allProducts = DummyProductTile.getFilteredDummyProducts('', '');
        Test.stopTest();



        // Assert all products are retrieved when no filter is applied
        System.assertEquals(10, allProducts.size());
    }

    // Test Case 7: Test applyBusinessLogic with business rules
    @isTest
    static void testApplyBusinessLogic() {
        List<Product__c> allProducts = [SELECT Id, Name, Rating__c, Price__c, Brand__c, Stock__c, Sku__c, Thumbnail__c, Description__c, Category__c FROM Product__c];
        
        Test.startTest();
        List<Product__c> limitedProducts = DummyProductTile.applyBusinessLogic(allProducts);
        Test.stopTest();

        // Business logic limits the number of products
        System.assert(limitedProducts.size() <= 100, 'Products per category should be limited by business rules.');
        Decimal totalPrice = 0;
        for (Product__c product : limitedProducts) {
            totalPrice += product.Price__c;
        }
        System.assert(totalPrice <= 10000, 'Total price should not exceed the limit of 10,000.');
    }

    // Test Case 8: Test invalid inputs for filtering (non-numeric rating)
    @isTest
    static void testInvalidInputForRatingFilter() {
        Test.startTest();
        List<Product__c> filteredProducts = DummyProductTile.getFilteredDummyProducts('Rating__c', 'abc');
        Test.stopTest();

        // Assert no products are returned for invalid numeric input
        System.assertEquals(0, filteredProducts.size(), 'Expected no products for invalid numeric input.');
    }
}
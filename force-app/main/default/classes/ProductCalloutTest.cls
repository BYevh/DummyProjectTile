@isTest
public class ProductCalloutTest {

    private static final String CONTENT_TYPE_HEADER = 'Content-Type';
    private static final String APPLICATION_JSON = 'application/json';
    private static final String SKU_36T6X4M3 = '36T6X4M3';
    private static final String REVIEW_EMAIL = 'testuser@dummy.com';
    private static final String NAME_SOME_PRODUCT = 'Some Product';
    private static final String COMMENT_GOOD_PRODUCT = 'Good product';
    private static final String MOCK_RESPONSE_BODY = '{' +
                                                        '"id": 1,' +
                                                        '"title": "' + NAME_SOME_PRODUCT + '",' +
                                                        '"description": "description",' +
                                                        '"category": "beauty",' +
                                                        '"price": 9.99,' +
                                                        '"discountPercentage": 7.17,' +
                                                        '"rating": 4.94,' +
                                                        '"stock": 5,' +
                                                        '"tags": [' +
                                                            '"beauty",' +
                                                            '"mascara"' +
                                                        '],' +
                                                        '"brand": "Essence",' +
                                                        '"sku": "36T6X4M3",' +
                                                        '"weight": 2,' +
                                                        '"dimensions": {' +
                                                            '"width": 23.17,' +
                                                            '"height": 14.43,' +
                                                            '"depth": 28.01' +
                                                        '},' +
                                                        '"warrantyInformation": "1 month warranty",' +
                                                        '"shippingInformation": "Ships in 1 month",' +
                                                        '"availabilityStatus": "Low Stock",' +
                                                        '"reviews": [' +
                                                            '{' +
                                                                '"rating": 2,' +
                                                                '"comment": "Very unhappy with my purchase!",' +
                                                                '"date": "2024-05-23T08:56:21.618Z",' +
                                                                '"reviewerName": "John Doe",' +
                                                                '"reviewerEmail": "john.doe@x.dummyjson.com"' +
                                                            '},' +
                                                            '{' +
                                                                '"rating": 2,' +
                                                                '"comment": "Not as described!",' +
                                                                '"date": "2024-05-23T08:56:21.618Z",' +
                                                                '"reviewerName": "Nolan Gonzalez",' +
                                                                '"reviewerEmail": "nolan.gonzalez@x.dummyjson.com"' +
                                                            '},' +
                                                            '{' +
                                                                '"rating": 5,' +
                                                                '"comment": "Very satisfied!",' +
                                                                '"date": "2024-05-23T08:56:21.618Z",' +
                                                                '"reviewerName": "Scarlett Wright",' +
                                                                '"reviewerEmail": "scarlett.wright@x.dummyjson.com"' +
                                                            '}' +
                                                        '],' +
                                                        '"returnPolicy": "30 days return policy",' +
                                                        '"minimumOrderQuantity": 24,' +
                                                        '"meta": {' +
                                                            '"createdAt": "2024-05-23T08:56:21.618Z",' +
                                                            '"updatedAt": "2024-05-23T08:56:21.618Z",' +
                                                            '"barcode": "9164035109868",' +
                                                            '"qrCode": "https://assets.dummyjson.com"' +
                                                        '},' +
                                                        '"images": [' +
                                                            '"https://cdn.dummyjson.com"' +
                                                        '],' +
                                                        '"thumbnail": "https://cdn.dummyjson.com"' +
                                                    '}';



    @testSetup
    static void setupTestData() {
        String body = DummyProductMapping.changeReservedWords(MOCK_RESPONSE_BODY);
        JsonParserProduct.product products = (JsonParserProduct.product) JSON.deserialize(body, JsonParserProduct.product.class);
         Product__c product = DummyProductMapping.mapProductFields(products);
        insert product;

        Review__c review = new Review__c(
            Dummy_Product__c = product.Id,
            Product_Sku__c = SKU_36T6X4M3,
            Email__c = REVIEW_EMAIL,
            Comment__c = COMMENT_GOOD_PRODUCT,
            Rating__c = 5.0
        );
        insert review;
    }

    @isTest
    static void testMakeGetCallout() {
        Test.setMock(HttpCalloutMock.class, new ProductCalloutMockResponse());

        Test.startTest();
        HttpResponse response = ProductCallout.makeGetCallout();
        Test.stopTest();

        System.assertEquals(200, response.getStatusCode(), 'Expected successful HTTP status code 200');

        Product__c insertedProduct = [SELECT Sku__c, Name FROM Product__c WHERE Sku__c = :SKU_36T6X4M3 LIMIT 1];
        System.assertNotEquals(null, insertedProduct);
        System.assertEquals(SKU_36T6X4M3, insertedProduct.Sku__c);
        System.assertEquals(NAME_SOME_PRODUCT, insertedProduct.Name);
    }

    @isTest
    static void testUpsertProductsAndReviewsAsync() {
        List<Product__c> products = new List<Product__c>{
            new Product__c(Sku__c = SKU_36T6X4M3, Name = NAME_SOME_PRODUCT, Price__c = 120.00)
        };
        List<Review__c> reviews = new List<Review__c>{
            new Review__c(Product_Sku__c = SKU_36T6X4M3, Email__c = REVIEW_EMAIL, Comment__c = COMMENT_GOOD_PRODUCT, Rating__c = 4.0)
        };

        String serializedProducts = JSON.serialize(products);
        Map<String, List<Review__c>> reviewsMap = new Map<String, List<Review__c>>{SKU_36T6X4M3 => reviews};
        String serializedReviewsMap = JSON.serialize(reviewsMap);

        Test.startTest();
        ProductCallout.upsertProductsAndReviewsAsync(serializedProducts, serializedReviewsMap);
        Test.stopTest();

        Product__c insertedProduct = [SELECT Sku__c, Name FROM Product__c WHERE Sku__c = :SKU_36T6X4M3 LIMIT 1];
        System.assertEquals(SKU_36T6X4M3, insertedProduct.Sku__c);
        System.assertEquals(NAME_SOME_PRODUCT, insertedProduct.Name);

        Review__c insertedReview = [SELECT Product_Sku__c, Email__c, Comment__c FROM Review__c WHERE Product_Sku__c = :SKU_36T6X4M3 LIMIT 1];
        System.assertEquals(SKU_36T6X4M3, insertedReview.Product_Sku__c);
        System.assertEquals(REVIEW_EMAIL, insertedReview.Email__c);
        System.assertEquals(COMMENT_GOOD_PRODUCT, insertedReview.Comment__c);
    }

    // Mocking class for HTTP Callout
    private class ProductCalloutMockResponse implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader(CONTENT_TYPE_HEADER, APPLICATION_JSON);
            res.setStatusCode(200);
            res.setBody(MOCK_RESPONSE_BODY);
            return res;
        }
    }
}
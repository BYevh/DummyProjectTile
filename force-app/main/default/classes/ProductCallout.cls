public with sharing class ProductCallout {

    public static HttpResponse makeGetCallout() {
        HttpResponse response = sendRequest('GET', 'callout:D_Product_Named_Credential/products?limit=0', null);
        
        if (response != null && response.getStatusCode() == 200) {
            try {
                String body = DummyProductMapping.changeReservedWords(response.getBody());
                JsonParserProduct results = (JsonParserProduct) JSON.deserialize(body, JsonParserProduct.class);
                List<JsonParserProduct.Product> products = results.products;
                
                if (!products.isEmpty()) {
                    List<Product__c> productForUpsert = new List<Product__c>();
                    Map<String, List<Review__c>> reviewsMap = new Map<String, List<Review__c>>();
                    
                    for (JsonParserProduct.Product product : products) {
                        Product__c newProduct = DummyProductMapping.mapProductFields(product);
                        productForUpsert.add(newProduct);

                        if (product.reviews != null && !product.reviews.isEmpty()) {
                            List<Review__c> productReviews = DummyProductMapping.mapReviews(product.reviews, product.sku);
                            reviewsMap.put(product.sku, productReviews);
                        }
                    }

                    String serializedProducts = JSON.serialize(productForUpsert);
                    String serializedReviewsMap = JSON.serialize(reviewsMap);

                    upsertProductsAndReviewsAsync(serializedProducts, serializedReviewsMap);
                }
            } catch (Exception ex) {
                System.debug('Error during deserialization or upsertion: ' + ex.getMessage());
            }
        }
        return response;
    }

    private static HttpResponse sendRequest(String method, String endpoint, String body) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod(method);
        
        if (body != null) {
            request.setHeader('Content-Type', 'application/json');
            request.setBody(body);
        }

        try {
            return http.send(request);
        } catch (Exception ex) {
            System.debug('HTTP request failed: ' + ex.getMessage());
            return null;
        }
    }

    
    //@future(callout=true)
    public static void upsertProductsAndReviewsAsync(String serializedProducts, String serializedReviewsMap) {
        try {
            List<Product__c> productsToUpsert = (List<Product__c>) JSON.deserialize(serializedProducts, List<Product__c>.class);
            Map<String, List<Review__c>> reviewsMap = (Map<String, List<Review__c>>) JSON.deserialize(serializedReviewsMap, Map<String, List<Review__c>>.class);

            Set<String> productSkus = new Set<String>();
            for (Product__c product : productsToUpsert) {
                productSkus.add(product.Sku__c);
            }

            upsert productsToUpsert Product__c.Sku__c;

            Map<String, Id> skuToProductIdMap = new Map<String, Id>();
            List<Product__c> fetchedProducts = [ 
                SELECT Id, Sku__c FROM Product__c WHERE Sku__c IN :productSkus
            ];

            for (Product__c p : fetchedProducts) {
                skuToProductIdMap.put(p.Sku__c, p.Id);
            }

            Map<String, Set<String>> existingReviewKeys = new Map<String, Set<String>>();

            List<Review__c> existingReviews = [
                SELECT Email__c, Comment__c, Rating__c, Product_Sku__c 
                FROM Review__c 
                WHERE Product_Sku__c IN :productSkus
            ];

            for (Review__c existingReview : existingReviews) {
                String productSku = existingReview.Product_Sku__c;
                String uniqueKey = generateUniqueKey(existingReview.Email__c, existingReview.Comment__c, existingReview.Rating__c); 
                if (!existingReviewKeys.containsKey(productSku)) {
                    existingReviewKeys.put(productSku, new Set<String>());
                }
                existingReviewKeys.get(productSku).add(uniqueKey);
            }

            List<Review__c> reviewsToInsert = new List<Review__c>();

            for (String sku : reviewsMap.keySet()) {
                Set<String> existingKeys = existingReviewKeys.containsKey(sku) ? existingReviewKeys.get(sku) : new Set<String>();

                if (skuToProductIdMap.containsKey(sku)) {
                    Id productId = skuToProductIdMap.get(sku);

                    for (Review__c review : reviewsMap.get(sku)) {
                        review.Dummy_Product__c = productId;
                        String uniqueKey = generateUniqueKey(review.Email__c, review.Comment__c, review.Rating__c);

                        if (!existingKeys.contains(uniqueKey)) {
                            reviewsToInsert.add(review);
                        }
                    }
                }
            }

            if (!reviewsToInsert.isEmpty()) {
                insert reviewsToInsert;
            }

        } catch (Exception ex) {
            System.debug('Error during upsert or insert: ' + ex.getMessage());
        }
    }

    private static String generateUniqueKey(String email, String comment, Decimal rating) {
        String normalizedComment = comment != null ? comment.trim().toLowerCase() : '';
        String normalizedEmail = email != null ? email.trim().toLowerCase() : '';
        String ratingString = (rating != null) ? String.valueOf(rating.setScale(2)) : '';
        return normalizedEmail + '-' + normalizedComment + '-' + ratingString;
    }
}
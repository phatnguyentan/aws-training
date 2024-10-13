package src;

import com.amazonaws.services.dax.AmazonDaxClient;
import com.amazonaws.services.dax.AmazonDax;
import com.amazonaws.services.dax.model.*;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDB;
import com.amazonaws.services.dynamodbv2.AmazonDynamoDBClientBuilder;
import com.amazonaws.services.dynamodbv2.document.DynamoDB;
import com.amazonaws.services.dynamodbv2.document.Table;
import com.amazonaws.services.dynamodbv2.model.AttributeValue;

import java.util.HashMap;
import java.util.Map;

public class DaxExample {
    private static final String DAX_ENDPOINT = "dax://your-dax-cluster-endpoint"; // Update with your DAX cluster
                                                                                  // endpoint
    private static final String USERS_TABLE = "Users";

    public static void main(String[] args) {
        // Create a DAX Client
        AmazonDax daxClient = AmazonDaxClient.builder()
                .withEndpointConfiguration(new EndpointConfiguration(DAX_ENDPOINT, "us-east-1")) // Change region if
                                                                                                 // needed
                .build();

        // Example usage
        putUser(daxClient, "user123", "john_doe", "http://example.com/profile.jpg", "Hello world!");
        Map<String, AttributeValue> user = getUser(daxClient, "user123");
        System.out.println("Retrieved User: " + user);
    }

    // Function to put an item into the Users table
    public static void putUser(AmazonDax daxClient, String userId, String username, String profilePicture, String bio) {
        Map<String, AttributeValue> item = new HashMap<>();
        item.put("UserID", new AttributeValue(userId));
        item.put("Username", new AttributeValue(username));
        item.put("ProfilePicture", new AttributeValue(profilePicture));
        item.put("Bio", new AttributeValue(bio));

        PutItemRequest putItemRequest = new PutItemRequest()
                .withTableName(USERS_TABLE)
                .withItem(item);
        daxClient.putItem(putItemRequest);
        System.out.println("User added: " + username);
    }

    // Function to get a user from the Users table
    public static Map<String, AttributeValue> getUser(AmazonDax daxClient, String userId) {
        GetItemRequest getItemRequest = new GetItemRequest()
                .withTableName(USERS_TABLE)
                .addKeyEntry("UserID", new AttributeValue(userId));

        GetItemResult result = daxClient.getItem(getItemRequest);
        return result.getItem();
    }
}
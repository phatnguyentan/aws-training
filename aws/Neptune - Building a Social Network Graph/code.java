import org.apache.tinkerpop.gremlin.driver.Cluster;
import org.apache.tinkerpop.gremlin.driver.Client;
import org.apache.tinkerpop.gremlin.process.traversal.dsl.graph.GraphTraversalSource;
import org.apache.tinkerpop.gremlin.structure.Graph;
import org.apache.tinkerpop.gremlin.structure.Vertex;

public class SocialNetworkGraph {
    private static final String NEPTUNE_ENDPOINT = "wss://<neptune-endpoint>:8182/gremlin"; // Replace with your Neptune
                                                                                            // endpoint

    public static void main(String[] args) {
        // Create a cluster and client to connect to the Neptune instance
        Cluster cluster = Cluster.build(NEPTUNE_ENDPOINT).create();
        Client client = cluster.connect();

        // Create a graph traversal source
        GraphTraversalSource g = client.submit("g").get().next();

        // Example: Add users
        addUser(g, "1", "Alice", 30);
        addUser(g, "2", "Bob", 25);
        addUser(g, "3", "Charlie", 35);

        // Example: Add friendships
        addFriendship(g, "1", "2");
        addFriendship(g, "1", "3");

        // Close the client and cluster
        client.close();
        cluster.close();
    }

    private static void addUser(GraphTraversalSource g, String userId, String name, int age) {
        g.addV("User")
                .property("user_id", userId)
                .property("name", name)
                .property("age", age)
                .next();
        System.out.println("Added user: " + name);
    }

    private static void addFriendship(GraphTraversalSource g, String userId1, String userId2) {
        g.V().has("User", "user_id", userId1).as("a")
                .V().has("User", "user_id", userId2)
                .addE("friends").from("a").next();
        System.out.println("Added friendship between: " + userId1 + " and " + userId2);
    }
}
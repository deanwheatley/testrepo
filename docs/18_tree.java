/**
 * Tree.java — Binary search tree with insert, search, and traversal.
 */
public class Tree {

    static class Node {
        int value;
        Node left, right;

        Node(int value) {
            this.value = value;
            this.left = null;
            this.right = null;
        }
    }

    private Node root;

    public void insert(int value) {
        root = insertRec(root, value);
    }

    private Node insertRec(Node node, int value) {
        if (node == null) return new Node(value);
        if (value < node.value) node.left = insertRec(node.left, value);
        else if (value > node.value) node.right = insertRec(node.right, value);
        return node;
    }

    public boolean search(int value) {
        return searchRec(root, value);
    }

    private boolean searchRec(Node node, int value) {
        if (node == null) return false;
        if (value == node.value) return true;
        if (value < node.value) return searchRec(node.left, value);
        return searchRec(node.right, value);
    }

    public void inorder() {
        inorderRec(root);
        System.out.println();
    }

    private void inorderRec(Node node) {
        if (node == null) return;
        inorderRec(node.left);
        System.out.print(node.value + " ");
        inorderRec(node.right);
    }

    public void preorder() {
        preorderRec(root);
        System.out.println();
    }

    private void preorderRec(Node node) {
        if (node == null) return;
        System.out.print(node.value + " ");
        preorderRec(node.left);
        preorderRec(node.right);
    }

    public static void main(String[] args) {
        Tree bst = new Tree();
        int[] values = {50, 30, 70, 20, 40, 60, 80};
        for (int v : values) bst.insert(v);

        System.out.print("Inorder:  "); bst.inorder();
        System.out.print("Preorder: "); bst.preorder();
        System.out.println("Search 40: " + bst.search(40));
        System.out.println("Search 99: " + bst.search(99));
    }
}

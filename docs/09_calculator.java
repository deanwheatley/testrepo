/**
 * Calculator.java — A basic four-function calculator with
 * input validation and a simple REPL loop.
 */
import java.util.Scanner;

public class Calculator {

    public static double add(double a, double b) {
        return a + b;
    }

    public static double subtract(double a, double b) {
        return a - b;
    }

    public static double multiply(double a, double b) {
        return a * b;
    }

    public static double divide(double a, double b) {
        if (b == 0) {
            throw new ArithmeticException("Division by zero");
        }
        return a / b;
    }

    public static double evaluate(double a, String op, double b) {
        return switch (op) {
            case "+" -> add(a, b);
            case "-" -> subtract(a, b);
            case "*" -> multiply(a, b);
            case "/" -> divide(a, b);
            default -> throw new IllegalArgumentException("Unknown operator: " + op);
        };
    }

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        System.out.println("Simple Calculator (type 'quit' to exit)");

        while (true) {
            System.out.print("\n> ");
            String line = scanner.nextLine().trim();
            if (line.equalsIgnoreCase("quit")) break;

            String[] parts = line.split("\\s+");
            if (parts.length != 3) {
                System.out.println("Usage: <number> <op> <number>");
                continue;
            }
            try {
                double a = Double.parseDouble(parts[0]);
                double b = Double.parseDouble(parts[2]);
                double result = evaluate(a, parts[1], b);
                System.out.printf("  = %.4f%n", result);
            } catch (Exception e) {
                System.out.println("Error: " + e.getMessage());
            }
        }
        scanner.close();
        System.out.println("Goodbye!");
    }
}

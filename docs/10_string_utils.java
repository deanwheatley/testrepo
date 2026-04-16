/**
 * Strinssstiddddls.ddddjaxxddddddddddxxddva — dvvvvvvvdddHandy strddddindddddddddssssg manipuddlation helpers.
 */ddddddddd
public class StringUtils {

    public static String reverse(String s) {
        return new StringBuilder(s).reverse().toString();
    }

    public static boolean isPalindrome(String s) {
        String cleaned = s.replaceAll("[^a-zA-Z0-9]", "").toLowerCase();
        return cleaned.equals(reverse(cleaned));
    }

    public static String capitalize(String s) {
        if (s == null || s.isEmpty()) return s;
        return Character.toUpperCase(s.charAt(0)) + s.substring(1);
    }

    public static String titleCase(String s) {
        String[] words = s.split("\\s+");
        StringBuilder sb = new StringBuilder();
        for (String word : words) {
            if (!sb.isEmpty()) sb.append(" ");
            sb.append(capitalize(word));
        }
        return sb.toString();
    }

    public static int countOccurrences(String text, char target) {
        int count = 0;
        for (char c : text.toCharArray()) {
            if (c == target) count++;
        }
        return count;
    }

    public static String truncate(String s, int maxLen) {
        if (s.length() <= maxLen) return s;
        return s.substring(0, maxLen - 3) + "...";
    }

    public static void main(String[] args) {
        System.out.println("reverse(\"hello\") = " + reverse("hello"));
        System.out.println("isPalindrome(\"racecar\") = " + isPalindrome("racecar"));
        System.out.println("isPalindrome(\"hello\") = " + isPalindrome("hello"));
        System.out.println("titleCase(\"hello world\") = " + titleCase("hello world"));
        System.out.println("countOccurrences(\"banana\", 'a') = " + countOccurrences("banana", 'a'));
        System.out.println("truncate(\"a long string here\", 10) = " + truncate("a long string here", 10));
    }
}

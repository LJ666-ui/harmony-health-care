import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class test_admin_login {
    public static void main(String[] args) {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        
        String rawPassword = "admin123";
        String encodedPassword = "$2a$10$N.z4rRE5rQ5dQ5dQ5dQ5dO5dQ5dQ5dQ5dQ5dQ5dQ5dQ5dQ5dQ5dQ5a";
        
        boolean matches = encoder.matches(rawPassword, encodedPassword);
        System.out.println("Password matches: " + matches);
        
        String correctHash = encoder.encode(rawPassword);
        System.out.println("Correct hash for 'admin123': " + correctHash);
    }
}

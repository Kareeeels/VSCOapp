package com.vsco.clone;

import com.vsco.clone.model.Post;
import com.vsco.clone.model.User;
import com.vsco.clone.repository.PostRepository;
import com.vsco.clone.repository.UserRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;

@SpringBootApplication
public class VscoCloneApplication {
    public static void main(String[] args) {
        SpringApplication.run(VscoCloneApplication.class, args);
    }

    @Bean
    public CommandLineRunner seedUsers(UserRepository userRepository) {
        return args -> {
            User user1 = new User();
            user1.setEmail("user@vsco.com");
            user1.setPassword("password");
            user1.setUsername("KAREL_VSCO");
            user1.setDisplayName("karellsw");
            user1.setBio("🏖️ 📸 🌿");
            user1.setWebsite("https://vsco.co/");
            user1.setProfilePicture("https://images.unsplash.com/photo-1500530855697-b586d89ba3ee");

            User user2 = new User();
            user2.setEmail("nature_explorer@vsco.com");
            user2.setPassword("password");
            user2.setUsername("nature_explorer");
            user2.setDisplayName("nature_explorer");
            user2.setBio("Chasing light outdoors.");
            user2.setWebsite("https://vsco.co/");
            user2.setProfilePicture("https://images.unsplash.com/photo-1502685104226-ee32379fefbe");

            User user3 = new User();
            user3.setEmail("urban_lines@vsco.com");
            user3.setPassword("password");
            user3.setUsername("urban_lines");
            user3.setDisplayName("urban_lines");
            user3.setBio("Architecture, steel and glass.");
            user3.setWebsite("https://vsco.co/");
            user3.setProfilePicture("https://images.unsplash.com/photo-1520975958225-1d6f3a070b39");

            User user4 = new User();
            user4.setEmail("guronybo@vsco.com");
            user4.setPassword("password");
            user4.setUsername("guronybo");
            user4.setDisplayName("guronybo");
            user4.setBio("Ocean edits and film looks.");
            user4.setWebsite("https://vsco.co/");
            user4.setProfilePicture("https://images.unsplash.com/photo-1524504388940-b1c1722653e1");

            User user5 = new User();
            user5.setEmail("dasvidaniyababy@vsco.com");
            user5.setPassword("password");
            user5.setUsername("dasvidaniyababy");
            user5.setDisplayName("dasvidaniyababy");
            user5.setBio("Colors, seasons, textures.");
            user5.setWebsite("https://vsco.co/");
            user5.setProfilePicture("https://images.unsplash.com/photo-1500648767791-00dcc994a43e");

            User user6 = new User();
            user6.setEmail("weswillison@vsco.com");
            user6.setPassword("password");
            user6.setUsername("weswillison");
            user6.setDisplayName("weswillison");
            user6.setBio("Minimal mood.");
            user6.setWebsite("https://vsco.co/");
            user6.setProfilePicture("https://images.unsplash.com/photo-1506794778202-cad84cf45f1d");

            User user7 = new User();
            user7.setEmail("alx-dag@vsco.com");
            user7.setPassword("password");
            user7.setUsername("alx-dag");
            user7.setDisplayName("alx-dag");
            user7.setBio("Still life + street.");
            user7.setWebsite("https://vsco.co/");
            user7.setProfilePicture("https://images.unsplash.com/photo-1527980965255-d3b416303d12");

            if (userRepository.findByUsername(user1.getUsername()).isEmpty()) userRepository.save(user1);
            if (userRepository.findByUsername(user2.getUsername()).isEmpty()) userRepository.save(user2);
            if (userRepository.findByUsername(user3.getUsername()).isEmpty()) userRepository.save(user3);
            if (userRepository.findByUsername(user4.getUsername()).isEmpty()) userRepository.save(user4);
            if (userRepository.findByUsername(user5.getUsername()).isEmpty()) userRepository.save(user5);
            if (userRepository.findByUsername(user6.getUsername()).isEmpty()) userRepository.save(user6);
            if (userRepository.findByUsername(user7.getUsername()).isEmpty()) userRepository.save(user7);
        };
    }

    @Bean
    public CommandLineRunner seedPosts(PostRepository postRepository) {
        return args -> {
            if (postRepository.count() > 0) {
                return;
            }

            Post post1 = new Post();
            post1.setImageUrl("https://images.unsplash.com/photo-1506744038136-46273834b3fb");
            post1.setUsername("nature_explorer");
            post1.setCaption("Quiet morning in the mountains.");
            post1.setLikes(124);
            post1.setFilter("none");

            Post post2 = new Post();
            post2.setImageUrl("https://images.unsplash.com/photo-1534067783941-51c9c23ecefd");
            post2.setUsername("urban_lines");
            post2.setCaption("Steel and glass.");
            post2.setLikes(89);
            post2.setFilter("none");

            postRepository.save(post1);
            postRepository.save(post2);
        };
    }
}

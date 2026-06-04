package com.vsco.clone.controller;

import com.vsco.clone.model.User;
import com.vsco.clone.repository.UserRepository;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    private final UserRepository userRepository;

    public UserController(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @GetMapping
    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @GetMapping("/{username}")
    public ResponseEntity<User> getByUsername(@PathVariable String username) {
        return userRepository.findByUsername(username)
            .map(ResponseEntity::ok)
            .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PutMapping("/{username}")
    public ResponseEntity<User> updateProfile(@PathVariable String username, @RequestBody Map<String, Object> payload) {
        Optional<User> existingOpt = userRepository.findByUsername(username);
        if (existingOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        User user = existingOpt.get();

        if (payload.containsKey("displayName")) {
            user.setDisplayName(payload.get("displayName") == null ? null : payload.get("displayName").toString());
        }
        if (payload.containsKey("bio")) {
            user.setBio(payload.get("bio") == null ? null : payload.get("bio").toString());
        }
        if (payload.containsKey("website")) {
            user.setWebsite(payload.get("website") == null ? null : payload.get("website").toString());
        }
        if (payload.containsKey("profilePicture")) {
            user.setProfilePicture(payload.get("profilePicture") == null ? null : payload.get("profilePicture").toString());
        }

        if (payload.containsKey("username")) {
            String newUsername = payload.get("username") == null ? null : payload.get("username").toString();
            if (newUsername != null && !newUsername.isBlank() && !newUsername.equals(user.getUsername())) {
                if (userRepository.findByUsername(newUsername).isPresent()) {
                    return ResponseEntity.status(409).build();
                }
                user.setUsername(newUsername);
            }
        }

        return ResponseEntity.ok(userRepository.save(user));
    }
}

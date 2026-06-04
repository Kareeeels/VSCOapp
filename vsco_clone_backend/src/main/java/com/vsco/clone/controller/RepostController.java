package com.vsco.clone.controller;

import com.vsco.clone.model.Post;
import com.vsco.clone.model.Repost;
import com.vsco.clone.model.User;
import com.vsco.clone.repository.PostRepository;
import com.vsco.clone.repository.RepostRepository;
import com.vsco.clone.repository.UserRepository;
import java.time.Instant;
import java.util.List;
import java.util.Optional;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/users/{username}/reposts")
@CrossOrigin(origins = "*")
public class RepostController {

    private final RepostRepository repostRepository;
    private final UserRepository userRepository;
    private final PostRepository postRepository;

    public RepostController(RepostRepository repostRepository, UserRepository userRepository, PostRepository postRepository) {
        this.repostRepository = repostRepository;
        this.userRepository = userRepository;
        this.postRepository = postRepository;
    }

    @GetMapping
    public ResponseEntity<List<Post>> getReposts(@PathVariable String username) {
        if (userRepository.findByUsername(username).isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        List<Post> posts = repostRepository.findByUserUsernameOrderByCreatedAtDesc(username).stream()
            .map(Repost::getPost)
            .toList();
        return ResponseEntity.ok(posts);
    }

    @PostMapping("/{postId}")
    public ResponseEntity<Post> repost(@PathVariable String username, @PathVariable Long postId) {
        Optional<User> userOpt = userRepository.findByUsername(username);
        if (userOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Optional<Post> postOpt = postRepository.findById(postId);
        if (postOpt.isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        Optional<Repost> existing = repostRepository.findByUserUsernameAndPostId(username, postId);
        if (existing.isPresent()) {
            return ResponseEntity.ok(existing.get().getPost());
        }

        Repost repost = new Repost();
        repost.setUser(userOpt.get());
        repost.setPost(postOpt.get());
        repost.setCreatedAt(Instant.now());
        repostRepository.save(repost);

        return ResponseEntity.ok(postOpt.get());
    }
}

package com.vsco.clone.controller;

import com.vsco.clone.model.Post;
import com.vsco.clone.repository.PostRepository;
import org.springframework.lang.NonNull;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/posts")
@CrossOrigin(origins = "*")
public class PostController {

    private final PostRepository postRepository;

    public PostController(PostRepository postRepository) {
        this.postRepository = postRepository;
    }

    @GetMapping
    public @NonNull List<Post> getAllPosts() {
        return postRepository.findAll();
    }

    @PostMapping
    public @NonNull Post createPost(@RequestBody @NonNull Post post) {
        return postRepository.save(post);
    }

    @PostMapping("/{id}/like")
    public @NonNull Post likePost(@PathVariable("id") @NonNull Long id) {
        Post post = postRepository.findById(id).orElseThrow(() -> new RuntimeException("Post not found"));
        post.setLikes(post.getLikes() + 1);
        return postRepository.save(post);
    }
}

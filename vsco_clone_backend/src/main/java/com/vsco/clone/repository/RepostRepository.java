package com.vsco.clone.repository;

import com.vsco.clone.model.Repost;
import java.util.List;
import java.util.Optional;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RepostRepository extends JpaRepository<Repost, Long> {
    List<Repost> findByUserUsernameOrderByCreatedAtDesc(String username);
    Optional<Repost> findByUserUsernameAndPostId(String username, Long postId);
}

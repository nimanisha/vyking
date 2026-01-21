package com.example.demo.controller;

import com.example.demo.model.UserRate;
import com.example.demo.repository.UserRateRepository; 
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")
@CrossOrigin(origins = "*")
public class UserController {

    @Autowired
    private UserRateRepository userRepository; 

    @GetMapping
    public List<UserRate> getAllUsers() {
        return userRepository.findAll();
    }

    @PostMapping
    public UserRate saveUser(@RequestBody UserRate userRate) {
        return userRepository.save(userRate);
    }
}
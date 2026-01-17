package com.example.demo.controller;

import com.example.demo.model.UserRate;
import com.example.demo.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController // تغییر مهم: تبدیل به RestController
@RequestMapping("/api/users") // تمام مسیرها با این پیشوند شروع می‌شوند
@CrossOrigin(origins = "*") // بسیار مهم: اجازه دادن به Nginx برای ارتباط با بک‌اِند
public class UserController {

    @Autowired
    private UserRepository userRepository;

    // گرفتن لیست همه کاربران به صورت JSON
    @GetMapping
    public List<UserRate> getAllUsers() {
        return userRepository.findAll();
    }

    // ذخیره کاربر جدید که به صورت JSON فرستاده شده است
    @PostMapping
    public UserRate saveUser(@RequestBody UserRate userRate) {
        return userRepository.save(userRate);
    }
}
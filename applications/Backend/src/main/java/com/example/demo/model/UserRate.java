package com.example.demo.model;

import jakarta.persistence.*;

@Entity
@Table(name = "users_rates")
public class UserRate {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String surname;
    private Integer rate;

    // Getters and Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getSurname() { return surname; }
    public void setSurname(String surname) { this.surname = surname; }
    public Integer getRate() { return rate; }
    public void setRate(Integer rate) { this.rate = rate; }
}
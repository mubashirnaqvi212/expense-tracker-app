package com.example.assignment02.model;

import jakarta.persistence.*;

@Entity
@Table(name = "users")   // make sure your DB table is also "users"
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id;   // better than int for JPA

    @Column(nullable = false)
    private String name;

    @Column(nullable = false, unique = true)
    private String email;

    private String country;

    @Column(nullable = false)
    private String password;

    @Column(nullable = false)
    private boolean banned = false;

    @Column(nullable = false)
    private boolean premium = false;

    public boolean isBanned() { return banned; }
    public void setBanned(boolean banned) { this.banned = banned; }

    public boolean isPremium() { return premium; }
    public void setPremium(boolean premium) { this.premium = premium; }

    // ================= REQUIRED BY JPA =================
    public User() {
        // JPA needs this
    }

    // ================= REGISTER CONSTRUCTOR =================
    public User(String name, String email, String country, String password) {
        this.name = name;
        this.email = email;
        this.country = country;
        this.password = password;
    }

    // ================= FULL CONSTRUCTOR (optional) =================
    public User(Integer id, String name, String email, String country, String password) {
        this.id = id;
        this.name = name;
        this.email = email;
        this.country = country;
        this.password = password;
        this.banned = false;
        this.premium = false;
    }

    // ================= GETTERS & SETTERS =================

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getCountry() {
        return country;
    }

    public void setCountry(String country) {
        this.country = country;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
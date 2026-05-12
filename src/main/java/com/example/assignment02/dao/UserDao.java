package com.example.assignment02.dao;

import com.example.assignment02.model.User;
import jakarta.persistence.*;

import java.util.List;

public class UserDao {

    private static final EntityManagerFactory emf =
            Persistence.createEntityManagerFactory("myPU");

    // ================= SAVE =================
    public void saveUser(User user) {

        EntityManager em = emf.createEntityManager();
        EntityTransaction tx = em.getTransaction();

        try {
            tx.begin();
            em.persist(user);
            tx.commit();

        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();

        } finally {
            em.close();
        }
    }

    // ================= UPDATE =================
    public void updateUser(User user) {

        EntityManager em = emf.createEntityManager();
        EntityTransaction tx = em.getTransaction();

        try {
            tx.begin();
            em.merge(user);
            tx.commit();

        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();

        } finally {
            em.close();
        }
    }

    // ================= DELETE =================
    public void deleteUser(int id) {

        EntityManager em = emf.createEntityManager();
        EntityTransaction tx = em.getTransaction();

        try {
            tx.begin();

            User user = em.find(User.class, id);
            if (user != null) {
                em.remove(user);
            }

            tx.commit();

        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();

        } finally {
            em.close();
        }
    }

    // ================= GET BY ID =================
    public User getUser(int id) {

        EntityManager em = emf.createEntityManager();

        try {
            return em.find(User.class, id);

        } finally {
            em.close();
        }
    }

    // ================= GET ALL =================
    public List<User> getAllUser() {

        EntityManager em = emf.createEntityManager();

        try {
            return em.createQuery("SELECT u FROM User u", User.class)
                    .getResultList();

        } finally {
            em.close();
        }
    }

    // ================= LOGIN (IMPORTANT) =================
    public User login(String email, String password) {

        EntityManager em = emf.createEntityManager();

        try {
            return em.createQuery(
                            "SELECT u FROM User u WHERE u.email = :email AND u.password = :password",
                            User.class)
                    .setParameter("email", email)
                    .setParameter("password", password)
                    .getSingleResult();

        } catch (Exception e) {
            return null;

        } finally {
            em.close();
        }
    }

    // ================= BAN USER =================
    public void banUser(int id) {
        EntityManager em = emf.createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User user = em.find(User.class, id);
            if (user != null) {
                user.setBanned(!user.isBanned()); // toggle
            }
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    // ================= RESET PASSWORD =================
    public void resetPassword(int id, String newPassword) {
        EntityManager em = emf.createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User user = em.find(User.class, id);
            if (user != null) {
                user.setPassword(newPassword);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }

    // ================= TOGGLE PREMIUM =================
    public void togglePremium(int id) {
        EntityManager em = emf.createEntityManager();
        EntityTransaction tx = em.getTransaction();
        try {
            tx.begin();
            User user = em.find(User.class, id);
            if (user != null) {
                user.setPremium(!user.isPremium());
            }
            tx.commit();
        } catch (Exception e) {
            if (tx.isActive()) tx.rollback();
            e.printStackTrace();
        } finally {
            em.close();
        }
    }
}
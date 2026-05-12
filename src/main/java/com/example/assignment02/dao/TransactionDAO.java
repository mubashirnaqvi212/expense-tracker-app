package com.example.assignment02.dao;

import com.example.assignment02.model.Transaction;
import com.example.assignment02.model.User;
import jakarta.persistence.*;

import java.util.List;

public class TransactionDAO {

    private static final EntityManagerFactory emf =
            Persistence.createEntityManagerFactory("myPU");

    // ================= SAVE =================
    public void addTransaction(Transaction transaction) {

        EntityManager em = emf.createEntityManager();
        EntityTransaction tx = em.getTransaction();

        try {

            tx.begin();

            em.persist(transaction);

            tx.commit();

        } catch (Exception e) {

            if (tx.isActive()) tx.rollback();
            e.printStackTrace();

        } finally {

            em.close();
        }
    }

    // ================= USER TRANSACTIONS =================
    public List<Transaction> getUserTransactions(User user) {

        EntityManager em = emf.createEntityManager();

        try {

            return em.createQuery(
                            "SELECT t FROM Transaction t WHERE t.user = :user ORDER BY t.date DESC",
                            Transaction.class
                    )
                    .setParameter("user", user)
                    .getResultList();

        } finally {

            em.close();
        }
    }

    // ================= USER INCOME =================
    public double getUserIncome(User user) {

        EntityManager em = emf.createEntityManager();

        try {

            Double total = em.createQuery(
                            "SELECT SUM(t.amount) FROM Transaction t WHERE t.type = 'income' AND t.user = :user",
                            Double.class
                    )
                    .setParameter("user", user)
                    .getSingleResult();

            return total != null ? total : 0;

        } finally {

            em.close();
        }
    }

    // ================= USER EXPENSE =================
    public double getUserExpenses(User user) {

        EntityManager em = emf.createEntityManager();

        try {

            Double total = em.createQuery(
                            "SELECT SUM(t.amount) FROM Transaction t WHERE t.type = 'expense' AND t.user = :user",
                            Double.class
                    )
                    .setParameter("user", user)
                    .getSingleResult();

            return total != null ? total : 0;

        } finally {

            em.close();
        }
    }
}
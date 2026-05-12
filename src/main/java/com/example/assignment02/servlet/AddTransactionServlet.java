package com.example.assignment02.servlet;

import com.example.assignment02.dao.TransactionDAO;
import com.example.assignment02.model.Transaction;
import com.example.assignment02.model.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/add-transaction")
public class AddTransactionServlet extends HttpServlet {

    private final TransactionDAO transactionDAO =
            new TransactionDAO();

    @Override
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session =
                request.getSession(false);

        if (session == null ||
                session.getAttribute("loggedUser") == null) {

            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        User user =
                (User) session.getAttribute("loggedUser");

        String type = request.getParameter("type");
        String category = request.getParameter("category");
        String description = request.getParameter("description");

        double amount =
                Double.parseDouble(request.getParameter("amount"));

        LocalDate date =
                LocalDate.parse(request.getParameter("date"));

        Transaction transaction = new Transaction();

        transaction.setType(type);
        transaction.setCategory(category);
        transaction.setDescription(description);
        transaction.setAmount(amount);
        transaction.setDate(date);

        // IMPORTANT
        transaction.setUser(user);

        transactionDAO.addTransaction(transaction);

        response.getWriter().write("success");
    }
}
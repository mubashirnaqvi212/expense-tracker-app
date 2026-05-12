package com.example.assignment02.servlet;

import com.example.assignment02.dao.TransactionDAO;
import com.example.assignment02.model.Transaction;
import com.example.assignment02.model.User;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.JsonPrimitive;
import com.google.gson.JsonSerializer;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.time.LocalDate;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/dashboard-data")
public class DashboardServlet extends HttpServlet {

    private final TransactionDAO transactionDAO =
            new TransactionDAO();

    @Override
    protected void doGet(HttpServletRequest request,
                         HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");

        HttpSession session = request.getSession(false);

        if (session == null ||
                session.getAttribute("loggedUser") == null) {

            response.sendError(HttpServletResponse.SC_UNAUTHORIZED);
            return;
        }

        User user =
                (User) session.getAttribute("loggedUser");

        double totalIncome =
                transactionDAO.getUserIncome(user);

        double totalExpenses =
                transactionDAO.getUserExpenses(user);

        List<Transaction> transactions =
                transactionDAO.getUserTransactions(user);

        Map<String, Object> data = new HashMap<>();

        data.put("income", totalIncome);
        data.put("expenses", totalExpenses);
        data.put("transactions", transactions);

        Gson gson = new GsonBuilder()
                .registerTypeAdapter(LocalDate.class,
                        (JsonSerializer<LocalDate>) (src, typeOfSrc, context) ->
                                new JsonPrimitive(src.toString()))
                .create();

        response.getWriter().write(gson.toJson(data));
    }
}
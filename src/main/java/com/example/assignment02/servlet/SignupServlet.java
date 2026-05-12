package com.example.assignment02.web;

import com.example.assignment02.dao.UserDao;
import com.example.assignment02.model.User;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;

@WebServlet("/signup")
public class SignupServlet extends HttpServlet {

    private UserDao userDao;

    @Override
    public void init() {
        userDao = new UserDao();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String country = request.getParameter("country");
        String password = request.getParameter("password");

        // Create user object
        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setCountry(country);
        user.setPassword(password);

        // Save in database
        userDao.saveUser(user);

        // Redirect to login page
        /*response.sendRedirect("index.html?signup=success");*/
        response.sendRedirect("login.html?signup=success");
    }
}
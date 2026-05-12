package com.example.assignment02.servlet;

import com.example.assignment02.dao.UserDao;
import com.example.assignment02.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    private UserDao userDao;

    @Override
    public void init() {
        userDao = new UserDao();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String email = request.getParameter("email");
        String password = request.getParameter("password");

        User user = userDao.login(email, password);

        if (user != null) {

            // ✅ CREATE SESSION
            HttpSession session = request.getSession();
            session.setAttribute("loggedUser", user);

            // optional timeout (30 min)
            session.setMaxInactiveInterval(30 * 60);

            // redirect to dashboard
            response.sendRedirect("dashboard.jsp");

        } else {
            // login failed
            /*response.sendRedirect("login.jsp?error=1");*/
            response.sendRedirect("login.html?error=1");
        }
    }
}
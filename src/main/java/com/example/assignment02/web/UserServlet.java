package com.example.assignment02.web;

import com.example.assignment02.dao.UserDao;
import com.example.assignment02.model.User;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import java.io.IOException;
import java.util.List;

@WebServlet("/users")   // ✅ FIXED (was "/")
public class UserServlet extends HttpServlet {

    private UserDao userDao;

    @Override
    public void init() {
        userDao = new UserDao();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");  // ✅ FIXED

        try {
            if (action == null) {
                listUsers(request, response);
                return;
            }

            switch (action) {

                case "new":
                    showForm(request, response);
                    break;

                case "insert":
                    insertUser(request, response);
                    break;

                case "delete":
                    deleteUser(request, response);
                    break;

                case "edit":
                    showEditForm(request, response);
                    break;

                case "update":
                    updateUser(request, response);
                    break;
                case "viewAsUser":
                    viewAsUser(request, response);
                    break;

                case "ban":
                    banUser(request, response);
                    break;

                case "resetPassword":
                    resetPassword(request, response);
                    break;

                case "togglePremium":
                    togglePremium(request, response);
                    break;

                default:
                    listUsers(request, response);
                    break;
            }

        } catch (Exception e) {
            throw new ServletException(e);
        }
    }

    // ================= LIST USERS =================
    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<User> users = userDao.getAllUser();
        request.setAttribute("listUser", users);

        request.getRequestDispatcher("user-list.jsp")
                .forward(request, response);
    }

    // ================= SHOW FORM =================
    private void showForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.getRequestDispatcher("user-form.jsp")
                .forward(request, response);
    }

    // ================= INSERT USER =================
    private void insertUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String country = request.getParameter("country");
        String password = request.getParameter("password");

        User user = new User();
        user.setName(name);
        user.setEmail(email);
        user.setCountry(country);
        user.setPassword(password);

        userDao.saveUser(user);

        response.sendRedirect("users");
    }

    // ================= SHOW EDIT FORM =================
    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        User existingUser = userDao.getUser(id);

        request.setAttribute("user", existingUser);

        request.getRequestDispatcher("user-form.jsp")
                .forward(request, response);
    }

    // ================= UPDATE USER =================
    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String country = request.getParameter("country");
        String password = request.getParameter("password");

        User user = new User(id, name, email, country, password);

        userDao.updateUser(user);

        response.sendRedirect("users");
    }

    // ================= DELETE USER =================
    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {

        int id = Integer.parseInt(request.getParameter("id"));

        userDao.deleteUser(id);

        response.sendRedirect("users");
    }

    // ================= VIEW AS USER =================
    private void viewAsUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        User user = userDao.getUser(id);

        // Store impersonated user in session, keep admin flag
        HttpSession session = request.getSession();
        session.setAttribute("adminUser", session.getAttribute("loggedUser")); // save admin
        session.setAttribute("loggedUser", user); // switch to this user

        response.sendRedirect("dashboard.jsp");
    }

    // ================= BAN USER =================
    private void banUser(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        userDao.banUser(id);
        response.sendRedirect("users");
    }

    // ================= RESET PASSWORD =================
    private void resetPassword(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        String newPassword = request.getParameter("newPassword");
        userDao.resetPassword(id, newPassword);
        response.sendRedirect("users");
    }

    // ================= TOGGLE PREMIUM =================
    private void togglePremium(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        int id = Integer.parseInt(request.getParameter("id"));
        userDao.togglePremium(id);
        response.sendRedirect("users");
    }
}
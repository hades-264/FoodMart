package com.gms.servlet;

import com.gms.model.User;
import com.gms.dao.UserDAO; 

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/editProfile")
public class EditProfileServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        HttpSession session = request.getSession(false); 

        if (session != null && session.getAttribute("loggedInUser") != null) {
            User loggedInUser = (User) session.getAttribute("loggedInUser");

            UserDAO userDAO = new UserDAO();
            User freshUserData = userDAO.findUserById(loggedInUser.getUserId()); //
            if (freshUserData != null) {
                loggedInUser = freshUserData; 
                session.setAttribute("loggedInUser", loggedInUser); 
            }

            String sectionFocus = request.getParameter("sectionFocus");
            String returnUrl = request.getParameter("returnUrl");

            request.setAttribute("currentUserToEdit", loggedInUser);
            request.setAttribute("sectionFocus", sectionFocus); // Pass to JSP
            request.setAttribute("returnUrl", returnUrl);     // Pass to JSP

            request.getRequestDispatcher("/editProfile.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/login.jsp?message=Please_login_to_edit_your_profile");
        }
    }
}
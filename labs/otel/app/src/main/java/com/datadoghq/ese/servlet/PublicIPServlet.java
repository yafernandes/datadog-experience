package com.datadoghq.ese.servlet;

import java.io.IOException;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.apache.http.client.fluent.Request;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.slf4j.MDC;

@WebServlet("/myip")
public class PublicIPServlet extends HttpServlet {

  private static final Logger logger = LoggerFactory.getLogger("lab");

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {

    resp.setContentType("text/html");
    logger.info("Logging with slf4j");
    String ip = Request.Get("http://ipv4.icanhazip.com").execute().returnContent().asString();
    logger.info("My ip is " + ip);
    resp.getWriter().println(ip);
    MDC.clear();
  }

}

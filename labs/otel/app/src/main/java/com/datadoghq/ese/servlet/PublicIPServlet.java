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

import io.opentelemetry.api.trace.Span;

@WebServlet("/myip")
public class PublicIPServlet extends HttpServlet {

  private static final Logger logger = LoggerFactory.getLogger("lab");

  @Override
  protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
    setOTelDatadogLogContext();
    resp.setContentType("text/html");
    logger.info("Logging with slf4j");
    String ip = Request.Get("http://ipv4.icanhazip.com").execute().returnContent().asString();
    logger.info("My ip is " + ip);
    resp.getWriter().println(ip);
    MDC.clear();
  }

  void setOTelDatadogLogContext() {
    if (Span.current().isRecording()) {
      String traceIdValue = Span.current().getSpanContext().getTraceId();
      String traceIdHexString = traceIdValue.substring(traceIdValue.length() - 16);
      long datadogTraceId = Long.parseUnsignedLong(traceIdHexString, 16);
      MDC.put("dd.trace_id", Long.toUnsignedString(datadogTraceId));

      String spanIdValue = Span.current().getSpanContext().getSpanId();
      String spanIdHexString = spanIdValue.substring(spanIdValue.length() - 16);
      long datadogSpanId = Long.parseUnsignedLong(spanIdHexString, 16);
      MDC.put("dd.span_id", Long.toUnsignedString(datadogSpanId));
    }
  }

}

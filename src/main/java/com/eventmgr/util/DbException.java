package com.eventmgr.util;
public class DbException extends RuntimeException {public final String sqlState;public DbException(java.sql.SQLException e){super(e);sqlState=e.getSQLState();}}

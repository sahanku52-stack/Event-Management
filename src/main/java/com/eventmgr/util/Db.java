package com.eventmgr.util;
import java.io.*;import java.sql.*;import java.util.*;
public final class Db {
 private static String url,user,password;
 static { try { Class.forName("com.mysql.cj.jdbc.Driver");try(InputStream in=Db.class.getClassLoader().getResourceAsStream("db.properties")){if(in!=null){Properties p=new Properties();p.load(in);url=p.getProperty("db.url");user=p.getProperty("db.user");password=p.getProperty("db.password");}}}catch(IOException|ClassNotFoundException e){throw new RuntimeException(e);} }
 private Db(){}
 public static Connection conn() throws SQLException {String u=System.getenv("DB_URL"),n=System.getenv("DB_USER"),p=System.getenv("DB_PASSWORD");return DriverManager.getConnection(u==null?url:u,n==null?user:n,p==null?password:p);}
 private static PreparedStatement prep(Connection c,String sql,Object...args)throws SQLException{PreparedStatement s=c.prepareStatement(sql);for(int i=0;i<args.length;i++)s.setObject(i+1,args[i]);return s;}
 public static List<Map<String,Object>> query(String sql,Object...args){try(Connection c=conn();PreparedStatement s=prep(c,sql,args);ResultSet r=s.executeQuery()){List<Map<String,Object>> out=new ArrayList<>();ResultSetMetaData m=r.getMetaData();while(r.next()){Map<String,Object>x=new LinkedHashMap<>();for(int i=1;i<=m.getColumnCount();i++){Object v=r.getObject(i);if(v instanceof java.sql.Date)v=v.toString();else if(v instanceof java.sql.Time)v=v.toString();else if(v instanceof java.sql.Timestamp)v=v.toString();x.put(m.getColumnLabel(i),v);}out.add(x);}return out;}catch(SQLException e){throw new DbException(e);}}
 public static Map<String,Object> one(String sql,Object...args){List<Map<String,Object>> a=query(sql,args);return a.isEmpty()?null:a.get(0);}
 public static long count(String sql,Object...args){Map<String,Object> r=one(sql,args);return r==null?0:((Number)r.values().iterator().next()).longValue();}
 public static int update(String sql,Object...args){try(Connection c=conn();PreparedStatement s=prep(c,sql,args)){return s.executeUpdate();}catch(SQLException e){throw new DbException(e);}}
 public static long insert(String sql,Object...args){try(Connection c=conn();PreparedStatement s=c.prepareStatement(sql,Statement.RETURN_GENERATED_KEYS)){for(int i=0;i<args.length;i++)s.setObject(i+1,args[i]);s.executeUpdate();try(ResultSet r=s.getGeneratedKeys()){return r.next()?r.getLong(1):0;}}catch(SQLException e){throw new DbException(e);}}
}

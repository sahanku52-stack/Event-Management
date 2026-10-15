package com.eventmgr.util;
public final class Settings {private Settings(){}public static String get(String k,String d){java.util.Map<String,Object> r=Db.one("SELECT setting_value FROM settings WHERE setting_key=?",k);return r==null?d:(String)r.get("setting_value");}public static boolean bool(String k,boolean d){return Boolean.parseBoolean(get(k,String.valueOf(d)));}}

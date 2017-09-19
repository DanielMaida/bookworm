package br.ufpe.cin.if962.Config;

import br.ufpe.cin.if962.Heuristics.HeuristicType;;

public final class Config {
	public static String userAgent = "Mozilla" ;
	public static String referrer = "http://www.google.com";
	public static String filePath = "../Pages/";
	public static HeuristicType heuristicType =  HeuristicType.BFS;
	public static int numberOfPages = 1000;
}

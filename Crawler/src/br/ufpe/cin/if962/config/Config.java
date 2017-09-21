package br.ufpe.cin.if962.config;

import br.ufpe.cin.if962.factories.heuristics.HeuristicType;
import br.ufpe.cin.if962.factories.queues.QueueType;;

public final class Config {
	
	public static String filePath = "../Pages/";
	public static HeuristicType heuristicType =  HeuristicType.StardustCrusaders;
	public static int numberOfPages = 1000;
	
	//DO NOT TOUCH
	public static QueueType queueType = (heuristicType==HeuristicType.BFS?QueueType.LINKED_LIST:QueueType.PRIORITY_QUEUE);
	public static String userAgent = "Mozilla" ;
	public static String referrer = "http://www.google.com";
}

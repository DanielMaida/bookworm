package br.ufpe.cin.if962.config;

import java.util.Arrays;
import java.util.List;

import br.ufpe.cin.if962.factories.heuristics.HeuristicType;
import br.ufpe.cin.if962.factories.queues.QueueType;;

public final class Config {
	
	public static String filePath = "../Pages/";
	public static HeuristicType heuristicType =  HeuristicType.BFS;
	public static int numberOfPages = 1000;
	
	
	//DO NOT TOUCH
	public static QueueType queueType = (heuristicType==HeuristicType.BFS?QueueType.LINKED_LIST:QueueType.PRIORITY_QUEUE);
	public static String userAgent = "Mozilla" ;
	public static String referrer = "http://www.google.com";
	public static List<String> userAgentList = Arrays.asList(new String[] {"*", userAgent});
	public static long delayBetweenRequests = 4 * 1000;
}

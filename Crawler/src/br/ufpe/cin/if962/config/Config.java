package br.ufpe.cin.if962.config;

import br.ufpe.cin.if962.factories.heuristics.HeuristicType;
import br.ufpe.cin.if962.factories.queues.QueueType;;

public final class Config {
	public static String userAgent = "Mozilla" ;
	public static String referrer = "http://www.google.com";
	public static String filePath = "../Pages/";
	public static HeuristicType heuristicType =  HeuristicType.BattleTendency;
	public static QueueType queueType = (heuristicType==HeuristicType.BFS?QueueType.LINKED_LIST:QueueType.PRIORITY_QUEUE);
	public static int numberOfPages = 1000;
}

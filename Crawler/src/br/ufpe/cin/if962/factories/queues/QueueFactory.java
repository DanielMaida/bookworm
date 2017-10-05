package br.ufpe.cin.if962.factories.queues;

import java.util.LinkedList;
import java.util.PriorityQueue;
import java.util.Queue;

import br.ufpe.cin.if962.base.Link;
import br.ufpe.cin.if962.base.LinkComparator;

public class QueueFactory {
	public static Queue<Link> getQueue(QueueType type) {
		switch (type) {
		case LINKED_LIST:
			return new LinkedList<Link>();
		case PRIORITY_QUEUE:
			return new PriorityQueue<Link>(new LinkComparator());
		default:
			return null;
		}
	}
}

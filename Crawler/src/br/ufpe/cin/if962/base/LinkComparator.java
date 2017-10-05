package br.ufpe.cin.if962.base;

import java.util.Comparator;

public class LinkComparator implements Comparator<Link> {

	@Override
	public int compare(Link o1, Link o2) {
		if(o1.rank < o2.rank) {
			return 1;
		}else if(o1.rank > o2.rank) {
			return -1;
		}else {
			return 0;
		}
	}
}

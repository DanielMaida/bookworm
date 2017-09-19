package br.ufpe.cin.if962.base;

public class Link {
	public String url;
	public double rank;
	
	public Link (String url) {
		this.url = url;
		this.rank = 0;
	}
	
	public Link (String url, double rank) {
		this.url = url;
		this.rank = rank;
	}
}

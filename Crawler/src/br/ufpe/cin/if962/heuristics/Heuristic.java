package br.ufpe.cin.if962.heuristics;

import org.jsoup.nodes.Element;

public interface Heuristic {
	public double score(Element element);
}

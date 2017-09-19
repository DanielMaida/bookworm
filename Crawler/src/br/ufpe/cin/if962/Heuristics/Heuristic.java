package br.ufpe.cin.if962.Heuristics;

import org.jsoup.nodes.Element;

public interface Heuristic {
	public double score(Element element);
}

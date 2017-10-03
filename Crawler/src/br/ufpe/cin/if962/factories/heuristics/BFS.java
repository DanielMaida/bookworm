package br.ufpe.cin.if962.factories.heuristics;

import org.jsoup.nodes.Element;

/**Any href = 0*/
public class BFS extends Heuristic{

	@Override
	public double score(Element element , String currentPageUrl, int numberOfLinksToPage) {
		return 0;
	}

}

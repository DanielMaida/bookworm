package br.ufpe.cin.if962.factories.heuristics;

import org.jsoup.nodes.Element;

/** Current Page url with keyword = 2; Current href with keyword = 1 */
public class BattleTendency extends Heuristic {
	
	//a ideia é achar a categoria de livros, e visitar links dentro dela primeiro
	@Override
	public double score(Element element, String currentPageUrl, int numberOfLinksToPage) {
		double score = 0;
		score+=hasKeyword(element.absUrl("href"))?1:0;
		if(hasKeyword(currentPageUrl))
			score = 2;
		return score;
	}

}

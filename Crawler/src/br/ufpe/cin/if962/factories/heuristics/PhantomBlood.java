package br.ufpe.cin.if962.factories.heuristics;

import org.jsoup.nodes.Element;

/** Current href with keyword = 1 */
public class PhantomBlood extends Heuristic {

	//a ideia é visitar links relacionados a livros
	@Override
	public double score(Element element , String currentPageUrl, int numberOfLinksToPage) {
		return hasKeyword(element.absUrl("href"))?1:0;
	}

}

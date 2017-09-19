package br.ufpe.cin.if962.heuristics;

public class HeuristicFactory {
	public static Heuristic getHeuristic(HeuristicType type) {
		switch (type) {
		case BFS:
			return new BFS();
		case BattleTendency:
			return new BattleTendency();
		case PhantomBlood:
			return new PhantomBlood();
		case StardustCrusaders:
			return new StardustCrusaders();
		default:
			return null;
		}
	}
}
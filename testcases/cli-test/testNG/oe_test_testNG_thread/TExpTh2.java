import org.testng.annotations.Test;
import org.testng.annotations.BeforeSuite;
import org.testng.annotations.AfterSuite;

public class TExpTh2 {
	private double beforetime;
	private double aftertime;

	@Test(invocationCount = 1000, threadPoolSize = 1000)
	public void testMethod() {
		System.out.println("Thread Id :" + Thread.currentThread().getId());
	}

	@BeforeSuite
	public void beforetest() {
		this.beforetime = System.currentTimeMillis();

	}

	@AfterSuite
	public void aftertest() {
		this.aftertime = System.currentTimeMillis();
		System.out.println("time is :" + (aftertime - beforetime));
	}
}
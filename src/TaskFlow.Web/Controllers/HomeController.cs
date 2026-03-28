using Microsoft.AspNetCore.Mvc;
using TaskFlow.Web.Models;

namespace TaskFlow.Web.Controllers;

public class HomeController : Controller
{
    private static List<TaskItem> _tasks = new()
    {
        new TaskItem { Id = 1, Title = "Setup CI/CD Pipeline", Priority = "High" },
        new TaskItem { Id = 2, Title = "Configure Kubernetes", Priority = "High" },
        new TaskItem { Id = 3, Title = "Setup Monitoring", Priority = "Medium" }
    };

    public IActionResult Index()
    {
        return View(_tasks);
    }

    [HttpPost]
    public IActionResult Create(TaskItem task)
    {
        task.Id = _tasks.Count + 1;
        task.CreatedAt = DateTime.UtcNow;
        _tasks.Add(task);
        return RedirectToAction("Index");
    }

    [HttpPost]
    public IActionResult Complete(int id)
    {
        var task = _tasks.FirstOrDefault(t => t.Id == id);
        if (task != null) task.IsCompleted = true;
        return RedirectToAction("Index");
    }

    [HttpPost]
    public IActionResult Delete(int id)
    {
        _tasks.RemoveAll(t => t.Id == id);
        return RedirectToAction("Index");
    }

    [HttpGet("/health")]
    public IActionResult Health()
    {
        return Ok(new { status = "healthy", timestamp = DateTime.UtcNow });
    }

    [HttpGet("/metrics-info")]
    public IActionResult MetricsInfo()
    {
        return Ok(new {
            total_tasks = _tasks.Count,
            completed = _tasks.Count(t => t.IsCompleted),
            pending = _tasks.Count(t => !t.IsCompleted)
        });
    }
}

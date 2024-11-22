class _FluxFEHomePageState extends State<FluxFEHomePage> {
  final TextEditingController _textController = TextEditingController();
  String _imageUrl = ''; // Holds the URL of the image to be displayed.
  final String _postUrl = 'https://api.bfl.ml/v1/flux-pro-1.1'; // Replace with your fixed URL
  bool _isLoading = false;

  // Load prompt from file
  Future<void> loadPromptFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/my_file.txt');

    if (await file.exists()) {
      String fileContent = await file.readAsString();
      print(fileContent);
    } else {
      print('File does not exist');
    }
  }
  // Function to send POST request
  Future<void> _sendPostRequest() async {
    final String textInput = _textController.text;
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(_postUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'text': textInput, // Include the text input as part of the body
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        setState(() {
          _imageUrl = responseBody['image_url']; // Assuming the response contains an 'image_url' key
        });
      } else {
        _showError('Failed to post: ${response.statusCode}');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to show error messages
  void _showError(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: 'Enter Text',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _sendPostRequest,
              child: _isLoading ? CircularProgressIndicator() : Text('Send Post Request'),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: Center(
                child: _imageUrl.isEmpty
                    ? Text('No Image')
                    : Image.network(
                        _imageUrl,
                        errorBuilder: (context, error, stackTrace) {
                          return Text('Failed to load image');
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}